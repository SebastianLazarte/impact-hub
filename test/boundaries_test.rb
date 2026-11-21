# frozen_string_literal: true

require "test_helper"

# Hard rules that Packwerk cannot see: Packwerk checks references between packs,
# but Rails, the database and HTTP clients are gems, not packs.
class BoundariesTest < ActiveSupport::TestCase
  IMPACT = Rails.root.join("packs/impact")
  FORBIDDEN = /\b(ActiveRecord|ApplicationRecord|ActiveJob|ActionController|Rails|Net::HTTP|Faraday|Llm\w*)\b/

  test "IH-7: impact code references no Rails, database, network or LLM constant" do
    offenders = Dir[IMPACT.join("app/**/*.rb")].filter_map do |path|
      hits = File.readlines(path).each_with_index.filter_map do |line, i|
        next if line.lstrip.start_with?("#")

        "#{Pathname(path).relative_path_from(Rails.root)}:#{i + 1}: #{line.strip}" if line.match?(FORBIDDEN)
      end
      hits.presence
    end.flatten

    assert_empty offenders, "impact must stay pure Ruby:\n#{offenders.join("\n")}"
  end

  test "IH-7: the impact pack declares no dependencies and enforces it strictly" do
    package = YAML.load_file(IMPACT.join("package.yml"))

    assert_equal "strict", package["enforce_dependencies"]
    assert_empty Array(package["dependencies"])
  end
end
