# frozen_string_literal: true

# Over a Surveys::PointAssessment; `source:` procs run with the point as self.
class SurveyPointResource < ApplicationResource
  typelize position: :number, name: :string, zone: :string, application: :string
  attribute(:position) { _1.record.position }
  attribute(:name) { _1.record.name }
  attribute(:zone) { _1.record.zone }
  attribute(:application) { SurveyText.application(_1.record) }

  many :facts, resource: FactRowResource, source: proc { SurveyText.facts(record) }
  one :energy, resource: EnergyRowResource, source: proc { SurveyText.energy(self) }
  one :outcome, resource: OutcomeRowResource, source: proc { SurveyText.outcome(self) }

  typelize :string, nullable: true
  attribute :recommendation do |point|
    point.assessment.recommendation&.name
  end

  typelize "string[]"
  attribute :other_fitting do |point|
    point.assessment.other_fitting.map(&:name)
  end

  many :barriers, resource: BarrierRowResource, source: proc { SurveyText.barriers(self) }
end
