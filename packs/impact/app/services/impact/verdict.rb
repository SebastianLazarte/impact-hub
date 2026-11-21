# frozen_string_literal: true

module Impact
  VERDICTS = %i[not_rated too_weak check_space does_not_fit fits].freeze

  # What one barrier does at one hazard point. `reason` is set only for `not_rated`
  # (:no_test_angle or :rises_with_angle); `unmeasured` names the facts the verdict rests
  # on that were estimated or declared.
  Verdict = Data.define(:barrier, :kind, :rating, :reason, :unmeasured)
end
