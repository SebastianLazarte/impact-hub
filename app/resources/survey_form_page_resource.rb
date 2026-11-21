# frozen_string_literal: true

# The choice lists of the new survey form, so the form hard-codes none (spec Q3).
class SurveyFormPageResource < ApplicationResource
  Choice = Data.define(:value, :label)
  Fact = Data.define(:key, :label, :unit)
  MODE_LABELS = { "on_site" => "On site", "remote" => "Remote" }.freeze

  many :modes, resource: ModeChoiceResource,
               source: ->(_) { Surveys::Survey::MODES.map { Choice.new(_1, MODE_LABELS.fetch(_1)) } }

  many :applications, resource: ApplicationChoiceResource,
               source: ->(_) { Impact::APPLICATIONS.map { Choice.new(_1.to_s, SurveyText::APPLICATION_LABELS.fetch(_1)) } }

  many :sources, resource: SourceChoiceResource,
               source: ->(_) { Impact::SOURCES.map { Choice.new(_1.to_s, _1.to_s) } }

  many :facts, resource: FactChoiceResource,
               source: ->(_) { Impact::FACTS.map { |key, fact| Fact.new(key.to_s, fact[:label].upcase_first, fact[:unit]) } }
end
