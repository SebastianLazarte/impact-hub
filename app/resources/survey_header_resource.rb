# frozen_string_literal: true

class SurveyHeaderResource < ApplicationResource
  typelize site_name: :string, customer_name: :string, mode: Surveys::Survey::MODES
  attributes :site_name, :customer_name, :mode

  typelize :string
  attribute :surveyed_on do |survey|
    QuantityFormat.date(survey.surveyed_on)
  end

  typelize :string, nullable: true
  attribute :notes do |survey|
    survey.notes
  end
end
