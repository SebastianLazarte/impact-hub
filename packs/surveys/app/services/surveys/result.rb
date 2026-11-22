# frozen_string_literal: true

module Surveys
  # What a use case that writes returns: the value, or one message per field path.
  Result = Data.define(:value, :errors) do
    def self.success(value) = new(value: value, errors: {})
    def self.failure(errors) = new(value: nil, errors: errors)

    def success? = errors.empty?
  end
end
