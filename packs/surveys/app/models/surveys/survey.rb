# frozen_string_literal: true

module Surveys
  class Survey < ActiveRecord::Base
    self.table_name = "surveys"

    MODES = %w[on_site remote].freeze

    has_many :hazard_points, -> { order(:position) }, class_name: "Surveys::HazardPoint",
      inverse_of: :survey, dependent: :destroy, autosave: true

    normalizes :site_name, :customer_name, :mode, :notes, with: ->(text) { text.strip.presence }

    validates :site_name, presence: { message: "Enter the site name." }
    validates :customer_name, presence: { message: "Enter the customer name." }
    validates :mode, inclusion: { in: MODES, message: "Choose on site or remote." }
    validate :date_is_a_date
    validate :has_a_point

    private

    # Rails falls back to loose parsing ("03/04/2026", "2026-11-21 abc"), so the raw text
    # must be exactly YYYY-MM-DD and also cast to a real date (P3).
    def date_is_a_date
      raw = surveyed_on_before_type_cast.to_s.strip
      if raw.empty?
        errors.add(:surveyed_on, "Enter the survey date.")
      elsif !raw.match?(/\A\d{4}-\d{2}-\d{2}\z/) || surveyed_on.nil?
        errors.add(:surveyed_on, "Enter a date, like 2026-11-21.")
      end
    end

    def has_a_point
      errors.add(:hazard_points, "Add at least one hazard point.") if hazard_points.empty?
    end
  end
end
