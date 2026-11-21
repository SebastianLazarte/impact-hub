# frozen_string_literal: true

require "bigdecimal"

module Scoring
  # The facts about one process step that scoring needs.
  # Validated on construction so a bad value fails here, not deep inside a rule.
  # Numbers become BigDecimal; an unknown number stays nil.
  StepInput = Data.define(
    :minutes_per_run, :runs_per_month, :input_type, :rule_clarity, :exception_rate, :sensitive_data
  ) do
    def initialize(minutes_per_run:, runs_per_month:, input_type:, rule_clarity:, exception_rate:, sensitive_data:)
      super(
        minutes_per_run: StepInput.non_negative(minutes_per_run, :minutes_per_run),
        runs_per_month: StepInput.non_negative(runs_per_month, :runs_per_month),
        input_type: StepInput.one_of(input_type, Levels::INPUT_TYPES, :input_type),
        rule_clarity: StepInput.one_of(rule_clarity, Levels::RULE_CLARITIES, :rule_clarity),
        exception_rate: StepInput.rate(exception_rate),
        sensitive_data: StepInput.boolean(sensitive_data, :sensitive_data)
      )
    end

    def self.decimal(value)
      return nil if value.nil?

      value.is_a?(Float) ? BigDecimal(value.to_s) : BigDecimal(value)
    end

    def self.non_negative(value, name)
      decimal(value).tap do |d|
        raise ArgumentError, "#{name} must be >= 0, got #{value.inspect}" if d&.negative?
      end
    end

    def self.rate(value)
      decimal(value).tap do |d|
        raise ArgumentError, "exception_rate must be within 0..1, got #{value.inspect}" if d && !(0..1).cover?(d)
      end
    end

    def self.one_of(value, allowed, name)
      symbol = value&.to_sym
      return symbol if allowed.include?(symbol)

      raise ArgumentError, "#{name} must be one of #{allowed.join(', ')}, got #{value.inspect}"
    end

    def self.boolean(value, name)
      return value if [ true, false ].include?(value)

      raise ArgumentError, "#{name} must be true or false, got #{value.inspect}"
    end
  end
end
