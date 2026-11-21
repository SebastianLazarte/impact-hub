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
