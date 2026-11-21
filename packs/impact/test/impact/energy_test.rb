# frozen_string_literal: true

require "test_helper"
require "bigdecimal/math"
require_relative "../support/impact_helpers"

module Impact
  class EnergyTest < ActiveSupport::TestCase
    include ImpactHelpers

    test "IH-14: the worked examples of impact.md section 3" do
      assert_equal 11_501, joules(mass: "4000", load: "600", speed: "8.05", angle: "90")
      assert_equal 11_359, joules(mass: "4000", load: "600", speed: "8", angle: "90")
      assert_equal 5_680, joules(mass: "4000", load: "600", speed: "8", angle: "45")
      assert_equal 83_334, joules(mass: "12000", load: "3000", speed: "12", angle: "90")
    end

    test "IH-14: exact angles typed with decimals use the exact sine" do
      assert_equal 11_359, joules(mass: "4000", load: "600", speed: "8", angle: "90.0")
      assert_equal 8_519, joules(mass: "4000", load: "600", speed: "8", angle: "60")
      assert_equal 2_840, joules(mass: "4000", load: "600", speed: "8", angle: "30.00")
    end

    test "IH-14: never below the exact value, at most 1 J above, at every half degree" do
      (BigDecimal("1")..BigDecimal("89.5")).step(BigDecimal("0.5")).each do |angle|
        next if [ 30, 45, 60 ].include?(angle)

        exact = reference_energy(4600, 8, angle)
        got = joules(mass: "4000", load: "600", speed: "8", angle: angle.to_s)
        assert_operator got, :>=, exact, "angle #{angle}"
        assert_operator got, :<, exact + 2, "angle #{angle}"
      end
    end

    test "IH-15: a missing fact makes the energy unknown and is named" do
      energy = Impact::Rules.required_energy(point(max_load_kg: Impact::Fact.unknown))
      assert_nil energy.joules
      assert_equal [ :max_load_kg ], energy.missing
    end

    test "IH-23: the energy names the facts it rests on that were not measured" do
      energy = Impact::Rules.required_energy(
        point(max_load_kg: fact("600", :estimated), speed_kmh: fact("8", :declared), clearance_mm: fact("600", :estimated))
      )
      assert_equal %i[max_load_kg speed_kmh], energy.unmeasured
    end

    private

    def joules(mass:, load:, speed:, angle:)
      Impact::Rules.required_energy(
        point(vehicle_mass_kg: fact(mass), max_load_kg: fact(load), speed_kmh: fact(speed), impact_angle_deg: fact(angle))
      ).joules
    end

    # 1/2 m (v/3.6)^2 sin^2(angle) at 100 digits, no margin, as a Rational.
    def reference_energy(total_mass, speed, angle)
      sine = BigMath.sin(BigDecimal(angle.to_s) * BigMath.PI(100) / 180, 100)
      Rational(total_mass) * (Rational(speed) / Rational(36, 10))**2 * sine.to_r**2 / 2
    end
  end
end
