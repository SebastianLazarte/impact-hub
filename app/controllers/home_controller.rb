# frozen_string_literal: true

# Phase 1-2 demo: scores a few sample steps with the scoring pack and renders them.
# Replaced by real requests from the intake pack in phase 3.
class HomeController < InertiaController
  SAMPLE_STEPS = [
    { name: "Copy order lines from email into the ERP", department: "Sales",
      minutes_per_run: 12, runs_per_month: 160, input_type: :semi, rule_clarity: :clear,
      exception_rate: "0.1", sensitive_data: false },
    { name: "Check stock and reorder below threshold", department: "Warehouse",
      minutes_per_run: 5, runs_per_month: 300, input_type: :structured, rule_clarity: :clear,
      exception_rate: "0.02", sensitive_data: false },
    { name: "Approve a customer credit limit", department: "Finance",
      minutes_per_run: 20, runs_per_month: 25, input_type: :structured, rule_clarity: :judgement,
      exception_rate: "0.5", sensitive_data: true },
    { name: "Summarise installer site reports", department: "Service",
      minutes_per_run: 25, runs_per_month: nil, input_type: :unstructured, rule_clarity: :partial,
      exception_rate: "0.25", sensitive_data: false }
  ].freeze

  def index
    render inertia: { steps: SAMPLE_STEPS.map { |s| present(s) } }
  end

  private

  def present(sample)
    facts = sample.except(:name, :department)
    score = Scoring::Rules.evaluate(Scoring::StepInput.new(**facts))

    {
      name: sample[:name],
      department: sample[:department],
      input_type: facts[:input_type],
      rule_clarity: facts[:rule_clarity],
      sensitive_data: facts[:sensitive_data],
      hours: estimate_json(score.hours_per_month) { |v| format("%.2f", v) },
      score: estimate_json(score.automation_score, &:itself),
      method: score.automation_method,
      control: score.required_control
    }
  end

  # Decimals go out as strings (spec P4); unknown goes out as null plus the reason.
  def estimate_json(estimate)
    { value: estimate.known? ? yield(estimate.value) : nil, reason: estimate.reason }
  end
end
