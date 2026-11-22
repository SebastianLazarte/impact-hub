# frozen_string_literal: true

class EnergyRowResource < ApplicationResource
  typelize value: [ :string, { nullable: true } ], reason: [ :string, { nullable: true } ], unmeasured: "string[]"
  attributes :value, :reason, :unmeasured
end
