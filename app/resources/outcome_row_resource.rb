# frozen_string_literal: true

class OutcomeRowResource < ApplicationResource
  typelize status: Impact::Outcomes::ALL.map(&:to_s), label: :string,
           reason: [ :string, { nullable: true } ], unmeasured: "string[]"
  attributes :status, :label, :reason, :unmeasured
end
