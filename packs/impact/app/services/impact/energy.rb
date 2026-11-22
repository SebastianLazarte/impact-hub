# frozen_string_literal: true

module Impact
  # The required energy of a hazard point. `joules` is nil when a fact is missing;
  # `missing` names those facts and `unmeasured` the facts the energy rests on that
  # were estimated or declared rather than measured.
  Energy = Data.define(:joules, :missing, :unmeasured) do
    def known? = !joules.nil?
  end
end
