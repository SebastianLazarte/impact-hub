# frozen_string_literal: true

module Impact
  # A barrier's tested energy (joules) at the test angle that applies to a hazard.
  Rating = Data.define(:angle_deg, :joules)
end
