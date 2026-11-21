# frozen_string_literal: true

# Attributes as the form posts them: string keys, raw strings.
module SurveyAttributes
  def s1
    {
      "site_name" => "Northgate DC",
      "customer_name" => "Acme Logistics",
      "surveyed_on" => "2026-11-21",
      "mode" => "on_site",
      "notes" => "",
      "hazard_points" => [
        {
          "name" => "Aisle 4 walkway", "zone" => "Aisle 4", "application" => "pedestrian",
          "vehicle_mass_kg" => "4000", "vehicle_mass_kg_source" => "measured",
          "max_load_kg" => "600", "max_load_kg_source" => "estimated",
          "speed_kmh" => "8", "speed_kmh_source" => "declared",
          "impact_angle_deg" => "90", "impact_angle_deg_source" => "estimated",
          "clearance_mm" => "600", "clearance_mm_source" => "measured"
        }
      ]
    }
  end

  def with_point(attrs, changes)
    attrs.merge("hazard_points" => [ attrs["hazard_points"][0].merge(changes), *attrs["hazard_points"][1..] ])
  end

  def create_survey(attrs)
    Surveys::CreateSurvey.call(attrs).value
  end
end
