# frozen_string_literal: true

class FactRowResource < ApplicationResource
  typelize label: :string, value: [ :string, { nullable: true } ],
           source: [ Impact::SOURCES.map(&:to_s), { nullable: true } ]
  attributes :label, :value, :source
end
