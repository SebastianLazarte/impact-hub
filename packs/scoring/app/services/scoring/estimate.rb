# frozen_string_literal: true

module Scoring
  # A computed number, or nil with the reason it could not be computed.
  # Unknown is never reported as 0.
  Estimate = Data.define(:value, :reason) do
    def self.known(value) = new(value:, reason: nil)
    def self.unknown(reason) = new(value: nil, reason:)

    def known? = !value.nil?
  end
end
