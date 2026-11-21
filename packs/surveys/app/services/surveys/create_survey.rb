# frozen_string_literal: true

module Surveys
  # Validates a whole survey with its points and saves all of it, or none (IH-20, IH-21).
  class CreateSurvey
    SURVEY_FIELDS = %w[site_name customer_name surveyed_on mode notes].freeze
    POINT_FIELDS = (%w[name zone application] + Impact::FACTS.keys.flat_map { [ _1.to_s, "#{_1}_source" ] }).freeze

    def self.call(attributes) = new(attributes).call

    def initialize(attributes)
      @attributes = attributes
    end

    def call
      survey = Survey.new(@attributes.slice(*SURVEY_FIELDS))
      Array(@attributes["hazard_points"]).each.with_index(1) do |point, position|
        survey.hazard_points.build(point.slice(*POINT_FIELDS).merge("position" => position))
      end

      errors = collect_errors(survey)
      return Result.failure(errors) if errors.any?

      survey.save!
      Result.success(survey)
    end

    private

    # One message per field, keyed as the form names its fields.
    def collect_errors(survey)
      survey.valid?
      errors = survey.errors.to_hash.transform_keys(&:to_s).transform_values(&:first)
      errors.reject! { |key, _| key.start_with?("hazard_points.") } # the points' own errors are re-keyed below
      survey.hazard_points.each.with_index do |point, index|
        point.errors.each { errors["hazard_points.#{index}.#{_1.attribute}"] ||= _1.message }
      end
      errors
    end
  end
end
