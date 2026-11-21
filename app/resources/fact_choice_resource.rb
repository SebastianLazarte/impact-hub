# frozen_string_literal: true

class FactChoiceResource < ApplicationResource
  typelize key: Impact::FACTS.keys.map(&:to_s), label: :string, unit: :string
  attributes :key, :label, :unit
end
