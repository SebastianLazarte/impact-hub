# frozen_string_literal: true

require "bigdecimal"

module Scoring
  # Pure scoring rules. Code computes every number; nothing here calls a model.
  #
  # Hours per month (IH-1, IH-2)
  #   minutes_per_run x runs_per_month / 60, BigDecimal, 2 places, half up.
  #   Missing minutes or runs -> unknown with a reason.
  #
  # Automation score, 0..100 (IH-3)
  #   input type     structured 50 | semi 30    | unstructured 10
  #   rule clarity   clear 50      | partial 25 | judgement 0
  #   exceptions     minus exception_rate x 50, rounded half up
  #   clamped to 0..100. Missing exception rate -> unknown with a reason.
  #
  # Method (IH-4)
  #   judgement -> human; structured + clear -> rules; anything else -> ai_assisted
  #
  # Required control (IH-5)
  #   rules -> none, ai_assisted -> review, human -> approve.
  #   Sensitive data raises it to at least approve. Rules only ever raise a control.
  module Rules
    INPUT_POINTS = { structured: 50, semi: 30, unstructured: 10 }.freeze
    CLARITY_POINTS = { clear: 50, partial: 25, judgement: 0 }.freeze
    EXCEPTION_WEIGHT = BigDecimal("50")
    MINUTES_PER_HOUR = BigDecimal("60")
    BASE_CONTROL = { rules: :none, ai_assisted: :review, human: :approve }.freeze
    SENSITIVE_MINIMUM = :approve

    module_function

    def hours_per_month(step)
      return Estimate.unknown("minutes per run not given") if step.minutes_per_run.nil?
      return Estimate.unknown("runs per month not given") if step.runs_per_month.nil?

      Estimate.known((step.minutes_per_run * step.runs_per_month / MINUTES_PER_HOUR).round(2, BigDecimal::ROUND_HALF_UP))
    end

    def automation_score(step)
      return Estimate.unknown("exception rate not given") if step.exception_rate.nil?

      penalty = (step.exception_rate * EXCEPTION_WEIGHT).round(0, BigDecimal::ROUND_HALF_UP).to_i
      raw = INPUT_POINTS.fetch(step.input_type) + CLARITY_POINTS.fetch(step.rule_clarity) - penalty
      Estimate.known(raw.clamp(0, 100))
    end

    def automation_method(step)
      return :human if step.rule_clarity == :judgement
      return :rules if step.input_type == :structured && step.rule_clarity == :clear

      :ai_assisted
    end

    def required_control(step)
      control = BASE_CONTROL.fetch(automation_method(step))
      step.sensitive_data ? Levels.stricter(control, SENSITIVE_MINIMUM) : control
    end

    def evaluate(step)
      StepScore.new(
        hours_per_month: hours_per_month(step),
        automation_score: automation_score(step),
        automation_method: automation_method(step),
        required_control: required_control(step)
      )
    end
  end
end
