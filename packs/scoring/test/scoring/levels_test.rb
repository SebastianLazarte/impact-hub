# frozen_string_literal: true

require "test_helper"

module Scoring
  class LevelsTest < ActiveSupport::TestCase
    test "IH-5: stricter never returns the lower control, in either order" do
      Levels::CONTROLS.product(Levels::CONTROLS).each do |a, b|
        result = Levels.stricter(a, b)

        assert_operator Levels.control_rank(result), :>=, Levels.control_rank(a)
        assert_operator Levels.control_rank(result), :>=, Levels.control_rank(b)
        assert_equal result, Levels.stricter(b, a)
      end
    end

    test "IH-6: an unknown control is an error, not the lowest rank" do
      assert_raises(ArgumentError) { Levels.control_rank(:maybe) }
      assert_raises(ArgumentError) { Levels.stricter(:none, :maybe) }
    end
  end
end
