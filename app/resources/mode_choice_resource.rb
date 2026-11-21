# frozen_string_literal: true

class ModeChoiceResource < ApplicationResource
  typelize value: Surveys::Survey::MODES, label: :string
  attributes :value, :label
end
