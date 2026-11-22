# frozen_string_literal: true

class BarrierRowResource < ApplicationResource
  typelize name: :string, deflection: :string, verdict: Impact::VERDICTS.map(&:to_s),
           rating: [ :string, { nullable: true } ], reason: [ :string, { nullable: true } ],
           unmeasured: "string[]"
  attributes :name, :rating, :deflection, :verdict, :reason, :unmeasured
end
