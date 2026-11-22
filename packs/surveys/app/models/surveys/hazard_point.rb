# frozen_string_literal: true

module Surveys
  class HazardPoint < ActiveRecord::Base
    self.table_name = "hazard_points"

    NUMBER = /\A-?\d+(\.\d+)?\z/

    belongs_to :survey, class_name: "Surveys::Survey", inverse_of: :hazard_points

    normalizes :name, :zone, :application, with: ->(text) { text.strip.presence }
    normalizes(*Impact::FACTS.keys.map { :"#{_1}_source" }, with: ->(text) { text.strip.presence })

    validates :name, presence: { message: "Enter a name for this point." }
    validates :zone, presence: { message: "Enter the zone." }
    validates :application, inclusion: { in: Impact::APPLICATIONS.map(&:to_s), message: "Choose an application." }
    validate :facts_are_valid

    # Each fact is checked on its raw text: Rails casts "abc" to 0 and "4,000" to 4 (P3).
    def facts_are_valid
      Impact::FACTS.each_key do |fact|
        source = public_send(:"#{fact}_source")
        raw = public_send(:"#{fact}_before_type_cast").to_s.strip

        if raw.empty?
          errors.add(fact, "Enter a value, or clear its source.") if source
        elsif !NUMBER.match?(raw)
          errors.add(fact, "Enter a number, like 8 or 8.5.")
        else
          message = Impact.out_of_range(fact, BigDecimal(raw))
          errors.add(fact, message) if message
        end

        if source.nil?
          errors.add(:"#{fact}_source", "Choose where this value came from.") unless raw.empty?
        elsif Impact::SOURCES.map(&:to_s).exclude?(source)
          errors.add(:"#{fact}_source", "Choose measured, estimated or declared.")
        end
      end
    end

    def to_impact
      Impact::HazardPoint.new(
        application: application.to_sym,
        **Impact::FACTS.keys.to_h do |fact|
          [ fact, Impact::Fact.new(value: public_send(fact), source: public_send(:"#{fact}_source")) ]
        end
      )
    end
  end
end
