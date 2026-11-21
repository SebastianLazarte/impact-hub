# frozen_string_literal: true

require "bigdecimal"

module Impact
  # One measured, estimated or declared value, or unknown (no value, no source).
  Fact = Data.define(:value, :source) do
    def initialize(value: nil, source: nil)
      raise ArgumentError, "a value needs a source" if !value.nil? && source.nil?
      raise ArgumentError, "a source needs a value" if value.nil? && !source.nil?

      super(value: Fact.decimal(value), source: Fact.source(source))
    end

    def self.unknown = new(value: nil, source: nil)

    def self.decimal(value)
      case value
      when nil then nil
      when BigDecimal then value
      when Integer then BigDecimal(value)
      when String then BigDecimal(value)
      else raise ArgumentError, "a fact value must be a String, Integer or BigDecimal, got #{value.class}"
      end
    end

    def self.source(source)
      return nil if source.nil?

      symbol = source.respond_to?(:to_sym) ? source.to_sym : source
      raise ArgumentError, "source must be one of #{SOURCES.inspect}, got #{source.inspect}" unless SOURCES.include?(symbol)

      symbol
    end

    def known? = !value.nil?

    def measured? = source == :measured
  end
end
