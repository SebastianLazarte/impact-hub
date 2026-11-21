# frozen_string_literal: true

class SurveySummaryResource < ApplicationResource
  typelize id: :number, site_name: :string, customer_name: :string,
           mode: Surveys::Survey::MODES
  attributes :id, :site_name, :customer_name, :mode

  typelize :string
  attribute :surveyed_on do |summary|
    QuantityFormat.date(summary.surveyed_on)
  end

  typelize :string
  attribute :points do |summary|
    "#{summary.point_count} #{'point'.pluralize(summary.point_count)}"
  end
end
