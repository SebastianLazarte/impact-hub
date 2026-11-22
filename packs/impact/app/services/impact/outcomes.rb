# frozen_string_literal: true

module Impact
  module Outcomes
    ALL = %i[incomplete specified needs_site_check engineering_review].freeze
    # Stricter to the right; `incomplete` is outside this order (impact.md section 6).
    ORDER = %i[specified needs_site_check engineering_review].freeze
  end
end
