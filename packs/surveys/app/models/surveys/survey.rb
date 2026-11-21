# frozen_string_literal: true

module Surveys
  class Survey < ActiveRecord::Base
    self.table_name = "surveys"

    MODES = %w[on_site remote].freeze

    has_many :hazard_points, -> { order(:position) }, class_name: "Surveys::HazardPoint",
      inverse_of: :survey, dependent: :destroy

    normalizes :site_name, :customer_name, :mode, :notes, with: ->(text) { text.strip.presence }

    validates :site_name, presence: { message: "Enter the site name." }
    validates :customer_name, presence: { message: "Enter the customer name." }
    validates :mode, inclusion: { in: MODES, message: "Choose on site or remote." }
    validate :date_is_a_date
    validate :has_a_point

    private

    # A string Rails cannot read as a date casts to nil; the raw text tells blank from garbage.
    def date_is_a_date
      return unless surveyed_on.nil?

      errors.add(:surveyed_on, surveyed_on_before_type_cast.to_s.strip.empty? ? "Enter the survey date." : "Enter a date, like 2026-11-21.")
    end

    def has_a_point
      errors.add(:hazard_points, "Add at least one hazard point.") if hazard_points.empty?
    end
  end
end
