# frozen_string_literal: true

module Scoring
  # Closed vocabularies shared by every scoring rule.
  module Levels
    INPUT_TYPES = %i[structured semi unstructured].freeze
    RULE_CLARITIES = %i[clear partial judgement].freeze
    METHODS = %i[rules ai_assisted human].freeze
    # Ordered from least to most human involvement. Order matters: see .stricter.
    CONTROLS = %i[none review approve].freeze

    module_function

    # The stricter of two controls. Any rule that "raises" a control goes through
    # here, so nothing can lower one by accident.
    def stricter(a, b)
      control_rank(a) >= control_rank(b) ? a : b
    end

    def control_rank(control)
      CONTROLS.index(control) || raise(ArgumentError, "unknown control: #{control.inspect}")
    end
  end
end
