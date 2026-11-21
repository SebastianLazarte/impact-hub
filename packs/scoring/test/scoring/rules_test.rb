# frozen_string_literal: true

require "test_helper"

module Scoring
  class RulesTest < ActiveSupport::TestCase
    RATES = (0..10).map { |i| BigDecimal(i) / 10 }.freeze

    def step(**overrides)
      StepInput.new(
        minutes_per_run: 15, runs_per_month: 40, input_type: :structured,
        rule_clarity: :clear, exception_rate: "0", sensitive_data: false, **overrides
      )
    end

    def every_step
      Levels::INPUT_TYPES.product(Levels::RULE_CLARITIES, RATES, [ true, false ]).map do |input, clarity, rate, sensitive|
        step(input_type: input, rule_clarity: clarity, exception_rate: rate, sensitive_data: sensitive)
      end
    end

    # --- IH-1 hours per month ---------------------------------------------

    test "IH-1: hours per month is minutes x runs / 60" do
      assert_equal BigDecimal("10"), Rules.hours_per_month(step).value
      assert_equal BigDecimal("0.35"), Rules.hours_per_month(step(minutes_per_run: 7, runs_per_month: 3)).value
    end

    test "IH-1: hours are a BigDecimal rounded to 2 places, never a Float" do
      hours = Rules.hours_per_month(step(minutes_per_run: 1, runs_per_month: 1)).value

      assert_kind_of BigDecimal, hours
      assert_equal BigDecimal("0.02"), hours # 1/60 = 0.0166... rounds half up
    end

    test "IH-1: zero runs is a known zero, not unknown" do
      estimate = Rules.hours_per_month(step(runs_per_month: 0))

      assert estimate.known?
      assert_equal BigDecimal("0"), estimate.value
    end

    # --- IH-2 unknown stays unknown ---------------------------------------

    test "IH-2: missing minutes or runs gives unknown hours with a reason" do
      no_minutes = Rules.hours_per_month(step(minutes_per_run: nil))
      no_runs = Rules.hours_per_month(step(runs_per_month: nil))

      assert_nil no_minutes.value
      assert_equal "minutes per run not given", no_minutes.reason
      assert_nil no_runs.value
      assert_equal "runs per month not given", no_runs.reason
    end

    test "IH-2: missing exception rate gives an unknown score, not 0" do
      score = Rules.automation_score(step(exception_rate: nil))

      refute score.known?
      assert_equal "exception rate not given", score.reason
    end

    # --- IH-3 automation score --------------------------------------------

    test "IH-3: decision table examples" do
      assert_equal 100, Rules.automation_score(step).value
      assert_equal 45, Rules.automation_score(step(input_type: :semi, rule_clarity: :partial, exception_rate: "0.2")).value
      assert_equal 0, Rules.automation_score(step(input_type: :unstructured, rule_clarity: :judgement, exception_rate: "1")).value
    end

    test "IH-3: the exception penalty rounds half up" do
      # 0.01 x 50 = 0.5 -> 1 point; 0.009 x 50 = 0.45 -> 0 points
      assert_equal 99, Rules.automation_score(step(exception_rate: "0.01")).value
      assert_equal 100, Rules.automation_score(step(exception_rate: "0.009")).value
    end

    test "IH-3: every combination scores an integer in 0..100" do
      every_step.each do |s|
        score = Rules.automation_score(s).value

        assert_kind_of Integer, score
        assert_includes 0..100, score, s.inspect
      end
    end

    test "IH-3: more exceptions never raise the score" do
      Levels::INPUT_TYPES.product(Levels::RULE_CLARITIES).each do |input, clarity|
        scores = RATES.map { |r| Rules.automation_score(step(input_type: input, rule_clarity: clarity, exception_rate: r)).value }

        assert_equal scores.sort.reverse, scores, "#{input}/#{clarity}"
      end
    end

    # --- IH-4 method --------------------------------------------------------

    test "IH-4: method follows input type and rule clarity" do
      expected = {
        [ :structured, :clear ] => :rules,
        [ :structured, :partial ] => :ai_assisted,
        [ :semi, :clear ] => :ai_assisted,
        [ :unstructured, :clear ] => :ai_assisted,
        [ :unstructured, :partial ] => :ai_assisted
      }
      Levels::INPUT_TYPES.each { |input| expected[[ input, :judgement ]] = :human }

      expected.each do |(input, clarity), method|
        assert_equal method, Rules.automation_method(step(input_type: input, rule_clarity: clarity)), "#{input}/#{clarity}"
      end
    end

    # --- IH-5 required control ----------------------------------------------

    test "IH-5: base control by method" do
      assert_equal :none, Rules.required_control(step)
      assert_equal :review, Rules.required_control(step(input_type: :semi))
      assert_equal :approve, Rules.required_control(step(rule_clarity: :judgement))
    end

    test "IH-5: sensitive data needs at least approve" do
      assert_equal :approve, Rules.required_control(step(sensitive_data: true))
    end

    test "IH-5: ai_assisted is never below review and sensitive is never below approve" do
      every_step.each do |s|
        rank = Levels.control_rank(Rules.required_control(s))

        assert_operator rank, :>=, Levels.control_rank(:review), s.inspect if Rules.automation_method(s) == :ai_assisted
        assert_operator rank, :>=, Levels.control_rank(:approve), s.inspect if s.sensitive_data
      end
    end

    test "IH-5: adding sensitive data never lowers the control" do
      every_step.reject(&:sensitive_data).each do |s|
        plain = Levels.control_rank(Rules.required_control(s))
        sensitive = Levels.control_rank(Rules.required_control(s.with(sensitive_data: true)))

        assert_operator sensitive, :>=, plain, s.inspect
      end
    end

    test "evaluate bundles every rule into one StepScore" do
      score = Rules.evaluate(step(input_type: :semi, sensitive_data: true))

      assert_equal BigDecimal("10"), score.hours_per_month.value
      assert_equal 80, score.automation_score.value
      assert_equal :ai_assisted, score.automation_method
      assert_equal :approve, score.required_control
    end
  end
end
