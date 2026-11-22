# frozen_string_literal: true

module Catalog
  class BarrierRating < ActiveRecord::Base
    belongs_to :barrier, class_name: "Catalog::Barrier"
  end
end
