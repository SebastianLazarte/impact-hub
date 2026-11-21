# frozen_string_literal: true

require "test_helper"

module Scoring
  class StepInputTest < ActiveSupport::TestCase
    VALID = {
      minutes_per_run: 15, runs_per_month: 40, input_type: :structured,
      rule_clarity: :clear, exception_rate: "0.1", sensitive_data: false
    }.freeze

    test "IH-1: numbers are stored as BigDecimal" do
      s = StepInput.new(**VALID, minutes_per_run: 2.5)

      assert_kind_of BigDecimal, s.minutes_per_run
      assert_kind_of BigDecimal, s.runs_per_month
      assert_kind_of BigDecimal, s.exception_rate
      assert_equal BigDecimal("2.5"), s.minutes_per_run
    end

    test "IH-6: vocabulary given as strings is accepted (form input)" do
      s = StepInput.new(**VALID, input_type: "semi", rule_clarity: "partial")

      assert_equal :semi, s.input_type
      assert_equal :partial, s.rule_clarity
    end

    test "IH-6: unknown vocabulary is rejected" do
      assert_raises(ArgumentError) { StepInput.new(**VALID, input_type: :spreadsheet) }
      assert_raises(ArgumentError) { StepInput.new(**VALID, rule_clarity: :fuzzy) }
    end

    test "IH-6: negative numbers are rejected" do
      assert_raises(ArgumentError) { StepInput.new(**VALID, minutes_per_run: -1) }
      assert_raises(ArgumentError) { StepInput.new(**VALID, runs_per_month: -1) }
    end

    test "IH-6: exception rate must be within 0..1" do
      assert_raises(ArgumentError) { StepInput.new(**VALID, exception_rate: "1.01") }
      assert_raises(ArgumentError) { StepInput.new(**VALID, exception_rate: "-0.1") }
      assert StepInput.new(**VALID, exception_rate: "1")
    end

    test "IH-6: sensitive_data must be a real boolean" do
      assert_raises(ArgumentError) { StepInput.new(**VALID, sensitive_data: nil) }
      assert_raises(ArgumentError) { StepInput.new(**VALID, sensitive_data: "yes") }
    end

    test "IH-2: unknown numbers stay nil" do
      s = StepInput.new(**VALID, minutes_per_run: nil, runs_per_month: nil, exception_rate: nil)

      assert_nil s.minutes_per_run
      assert_nil s.runs_per_month
      assert_nil s.exception_rate
    end
  end
end
