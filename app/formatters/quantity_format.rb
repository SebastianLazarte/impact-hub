# frozen_string_literal: true

# The one place numbers and dates become text for pages (spec Q3, ADR 0006).
module QuantityFormat
  UNSPACED_UNITS = %w[°].freeze

  # Only exact numbers: nil would become "0" and a Float would carry binary noise (P3, P4).
  def self.amount(value, unit)
    raise ArgumentError, "expected an Integer or BigDecimal, got #{value.inspect}" unless value.is_a?(Integer) || value.is_a?(BigDecimal)

    number = format_number(value)
    UNSPACED_UNITS.include?(unit) ? "#{number}#{unit}" : "#{number} #{unit}"
  end

  def self.date(date)
    date.strftime("%-d %b %Y")
  end

  def self.format_number(value)
    text = value.is_a?(Integer) ? value.to_s : value.to_d.to_s("F")
    whole, fraction = text.split(".")
    fraction = nil if fraction.to_s.match?(/\A0*\z/)
    whole = whole.reverse.scan(/\d{1,3}/).join(",").reverse
    whole = "-#{whole}" if text.start_with?("-")
    fraction ? "#{whole}.#{fraction.sub(/0+\z/, '')}" : whole
  end
  private_class_method :format_number
end
