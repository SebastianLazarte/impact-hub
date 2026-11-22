# frozen_string_literal: true

class SourceChoiceResource < ApplicationResource
  typelize value: Impact::SOURCES.map(&:to_s), label: :string
  attributes :value, :label
end
