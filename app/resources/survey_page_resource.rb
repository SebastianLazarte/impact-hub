# frozen_string_literal: true

class SurveyPageResource < ApplicationResource
  one :survey, resource: SurveyHeaderResource
  many :points, resource: SurveyPointResource

  typelize :string
  attribute :catalog_notice do |_assessment|
    Catalog::NOTICE
  end
end
