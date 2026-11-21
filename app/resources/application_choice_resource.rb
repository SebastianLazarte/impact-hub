# frozen_string_literal: true

class ApplicationChoiceResource < ApplicationResource
  typelize value: Impact::APPLICATIONS.map(&:to_s), label: :string
  attributes :value, :label
end
