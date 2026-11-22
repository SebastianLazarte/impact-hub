# frozen_string_literal: true

# The read-only, fictional, seeded list of barriers the impact rules choose from.
module Catalog
  NOTICE = "example values, not manufacturer data"

  def self.table_name_prefix = "catalog_"

  # { application => [Impact::Barrier] }; every requested application is a key.
  def self.barriers_for(applications)
    apps = Array(applications).map(&:to_sym)
    found = Barrier.where(application: apps.map(&:to_s)).includes(:ratings).order(:name).map(&:to_impact)
    apps.to_h { |app| [ app, found.select { _1.application == app } ] }
  end
end
