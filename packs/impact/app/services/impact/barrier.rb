# frozen_string_literal: true

require "bigdecimal"

module Impact
  # A catalog barrier: its deflection and the energy (joules) it is rated for at each test angle.
  Barrier = Data.define(:name, :application, :deflection_mm, :ratings) do
    def initialize(name:, application:, deflection_mm:, ratings:)
      unless APPLICATIONS.include?(application)
        raise ArgumentError, "application must be one of #{APPLICATIONS.inspect}, got #{application.inspect}"
      end

      super(
        name: name,
        application: application,
        deflection_mm: Fact.decimal(deflection_mm),
        ratings: ratings.to_h { |angle, energy| [ Fact.decimal(angle), Integer(energy) ] }.freeze
      )
    end
  end
end
