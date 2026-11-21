# frozen_string_literal: true

require "test_helper"

# Every acceptance criterion has a test, and every test id points at a real criterion.
class TraceabilityTest < ActiveSupport::TestCase
  ID = /\btest "(IH-\d+):/

  def requirement_ids
    YAML.load_file(Rails.root.join("docs/requirements.yml")).keys
  end

  def tested_ids
    Dir[Rails.root.join("{test,packs/*/test}/**/*_test.rb")].flat_map { |f| File.read(f).scan(ID).flatten }.uniq
  end

  test "every acceptance criterion has at least one test" do
    assert_empty requirement_ids - tested_ids, "criteria without a test"
  end

  test "every test id names a real acceptance criterion" do
    assert_empty tested_ids - requirement_ids, "tests pointing at unknown criteria"
  end
end
