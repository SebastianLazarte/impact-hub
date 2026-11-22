# frozen_string_literal: true

require "test_helper"

class CatalogTest < ActiveSupport::TestCase
  test "the seed is idempotent" do
    2.times { Catalog::Seed.call }
    assert_equal [ 12, 24 ], [ Catalog::Barrier.count, Catalog::BarrierRating.count ]
  end

  test "every seeded barrier is tested at 45 and 90 degrees, never higher at 90" do
    Catalog::Seed.call
    Catalog.barriers_for(Impact::APPLICATIONS).values.flatten.each do |b|
      assert_equal [ BigDecimal("45"), BigDecimal("90") ], b.ratings.keys.sort
      assert_operator b.ratings[BigDecimal("90")], :<=, b.ratings[BigDecimal("45")]
    end
  end

  test "barriers_for returns impact barriers per application" do
    Catalog::Seed.call
    found = Catalog.barriers_for(%i[pedestrian column])
    assert_equal %w[PR-12 PR-18 PR-24 PR-4], found[:pedestrian].map(&:name).sort
    assert_equal BigDecimal("450"), found[:pedestrian].find { _1.name == "PR-12" }.deflection_mm
  end
end
