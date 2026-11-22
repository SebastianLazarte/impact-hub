# frozen_string_literal: true

module Impact
  # One place where a vehicle could hit something that must be protected.
  # Validated on construction so a bad value fails here, not deep inside a rule.
  HazardPoint = Data.define(:application, *FACTS.keys) do
    def initialize(application:, **facts)
      unless APPLICATIONS.include?(application)
        raise ArgumentError, "application must be one of #{APPLICATIONS.inspect}, got #{application.inspect}"
      end

      FACTS.each_key do |key|
        fact = facts.fetch(key, Fact.unknown)
        raise ArgumentError, "#{key} must be an Impact::Fact" unless fact.is_a?(Fact)

        message = fact.known? && Impact.out_of_range(key, fact.value)
        raise ArgumentError, message if message
      end

      super(application: application, **FACTS.keys.to_h { |key| [ key, facts.fetch(key, Fact.unknown) ] })
    end
  end
end
