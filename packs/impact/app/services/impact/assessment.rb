# frozen_string_literal: true

module Impact
  # The outcome of one hazard point against a list of barriers. `verdicts` is empty when
  # the energy is unknown; `recommendation` is a Barrier or nil; `other_fitting` are the
  # remaining fitting barriers; `unmeasured` names the facts the outcome rests on that
  # were estimated or declared. `reason` is :missing_facts, :clearance_not_given,
  # :no_barrier_rated_high_enough, :covering_barriers_do_not_fit, or nil when specified.
  Assessment = Data.define(:energy, :verdicts, :outcome, :reason, :recommendation, :other_fitting, :unmeasured)
end
