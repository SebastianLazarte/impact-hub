# frozen_string_literal: true

require "bigdecimal"
require "bigdecimal/math"

module Impact
  # The rules of the pack. Pure functions of their arguments (ADR 0001 for the energy).
  module Rules
    DIGITS = 50
    MARGIN = BigDecimal("1e-40")
    EXACT_SIN2 = { 30 => Rational(1, 4), 45 => Rational(1, 2), 60 => Rational(3, 4), 90 => Rational(1) }.freeze

    module_function

    # E = 1/2 (mass + load) (speed / 3.6 * sin angle)^2 in whole joules, rounded up.
    # Exact fractions throughout; sin^2 is exact at 30, 45, 60 and 90 degrees and an
    # upper bound elsewhere, so the result is never below the exact energy (P1).
    def required_energy(point)
      facts = ENERGY_FACTS.to_h { |key| [ key, point.public_send(key) ] }
      missing = facts.reject { |_, fact| fact.known? }.keys
      unmeasured = facts.select { |_, fact| fact.known? && !fact.measured? }.keys
      return Energy.new(joules: nil, missing: missing, unmeasured: unmeasured) if missing.any?

      mass, load, speed, angle = facts.values.map(&:value)
      joules = ((mass + load).to_r * (speed.to_r / Rational(36, 10))**2 * sin_squared(angle) / 2).ceil
      Energy.new(joules: joules, missing: [], unmeasured: unmeasured)
    end

    # The barrier's tested energy at the smallest test angle not below the hazard's, or
    # nil when it has none or its energy rises with the angle (P1).
    def rating(barrier, angle_deg)
      return nil unless unrated_reason(barrier, angle_deg).nil?

      angle, joules = barrier.ratings.select { |test_angle, _| test_angle >= angle_deg }.min_by(&:first)
      Rating.new(angle_deg: angle, joules: joules)
    end

    # The first matching row of impact.md section 5; call it only with a known energy (P1, P2).
    def verdict(point, energy, barrier)
      clearance = point.clearance_mm
      unmeasured = unmeasured_facts(point, energy)
      rating = rating(barrier, point.impact_angle_deg.value)
      reason = unrated_reason(barrier, point.impact_angle_deg.value)

      kind =
        if rating.nil? then :not_rated
        elsif rating.joules < energy.joules then :too_weak
        elsif !clearance.known? then :check_space
        elsif barrier.deflection_mm > clearance.value then :does_not_fit
        else :fits
        end
      Verdict.new(barrier: barrier, kind: kind, rating: rating, reason: reason, unmeasured: unmeasured)
    end

    # The first matching row of impact.md section 6, over the barriers of the point's application.
    def assess(point, barriers)
      energy = required_energy(point)
      unmeasured = unmeasured_facts(point, energy)
      if energy.joules.nil?
        return Assessment.new(energy: energy, verdicts: [], outcome: :incomplete, reason: :missing_facts,
                              recommendation: nil, other_fitting: [], unmeasured: unmeasured)
      end

      verdicts = barriers.select { |barrier| barrier.application == point.application }
                         .map { |barrier| verdict(point, energy, barrier) }
      kinds = verdicts.map(&:kind)
      fitting = verdicts.select { |v| v.kind == :fits }
                        .sort_by { |v| [ v.rating.joules, v.barrier.deflection_mm, v.barrier.name ] }.map(&:barrier)

      outcome, reason =
        if fitting.any? then [ :specified, nil ]
        elsif kinds.include?(:check_space) then [ :needs_site_check, :clearance_not_given ]
        elsif kinds.include?(:does_not_fit) then [ :engineering_review, :covering_barriers_do_not_fit ]
        else [ :engineering_review, :no_barrier_rated_high_enough ]
        end
      Assessment.new(energy: energy, verdicts: verdicts, outcome: outcome, reason: reason,
                     recommendation: fitting.first, other_fitting: fitting.drop(1), unmeasured: unmeasured)
    end

    # The facts a result rests on that were not measured: the energy's, plus the clearance when it has a value.
    def unmeasured_facts(point, energy)
      clearance = point.clearance_mm
      energy.unmeasured + (clearance.known? && !clearance.measured? ? [ :clearance_mm ] : [])
    end
    private_class_method :unmeasured_facts
    private :unmeasured_facts

    def unrated_reason(barrier, angle_deg)
      return :no_test_angle if barrier.ratings.keys.none? { |test_angle| test_angle >= angle_deg }

      by_angle = barrier.ratings.sort.map(&:last)
      :rises_with_angle if by_angle.combination(2).any? { |smaller_angle, larger_angle| larger_angle > smaller_angle }
    end
    private_class_method :unrated_reason
    private :unrated_reason

    def sin_squared(angle)
      exact = EXACT_SIN2.find { |degrees, _| angle == degrees }&.last
      return exact if exact

      sine = [ BigMath.sin(angle * BigMath.PI(DIGITS) / 180, DIGITS) + MARGIN, 1 ].min
      sine.to_r**2
    end
    private_class_method :sin_squared
    private :sin_squared
  end
end
