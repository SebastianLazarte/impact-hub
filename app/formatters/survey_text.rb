# frozen_string_literal: true

# The sentences and rows of the survey page, written once on the server (spec Q3, ADR 0006).
module SurveyText
  FactRow = Data.define(:label, :value, :source)
  EnergyRow = Data.define(:value, :reason, :unmeasured)
  OutcomeRow = Data.define(:status, :label, :reason, :unmeasured)
  BarrierRow = Data.define(:name, :rating, :deflection, :verdict, :reason, :unmeasured)

  OUTCOME_LABELS = {
    incomplete: "Incomplete", specified: "Specified", needs_site_check: "Needs a site check",
    engineering_review: "Engineering review"
  }.freeze

  APPLICATION_LABELS = {
    pedestrian: "Pedestrian", traffic: "Traffic", rack_end: "Rack end", column: "Column", machine: "Machine"
  }.freeze

  OUTCOME_REASONS = {
    clearance_not_given: "clearance not given",
    no_barrier_rated_high_enough: "no barrier rated high enough",
    covering_barriers_do_not_fit: "the barriers that cover it do not fit the space"
  }.freeze

  UNRATED_REASONS = {
    no_test_angle: "not tested at 60° or steeper",
    rises_with_angle: "its tested energy rises with the angle"
  }.freeze

  module_function

  def application(record) = APPLICATION_LABELS.fetch(record.application.to_sym)

  def facts(record)
    Impact::FACTS.map do |key, fact|
      value = record.public_send(key)
      FactRow.new(label: fact[:label].capitalize,
        value: value && QuantityFormat.amount(value, fact[:unit]),
        source: record.public_send(:"#{key}_source"))
    end
  end

  def energy(point)
    energy = point.assessment.energy
    EnergyRow.new(value: energy.joules && QuantityFormat.amount(energy.joules, "J"),
      reason: missing(energy.missing),
      unmeasured: unmeasured(energy.unmeasured, point.record))
  end

  def outcome(point)
    assessment = point.assessment
    reason = assessment.reason == :missing_facts ? missing(assessment.energy.missing) : OUTCOME_REASONS[assessment.reason]
    OutcomeRow.new(status: assessment.outcome.to_s, label: OUTCOME_LABELS.fetch(assessment.outcome),
      reason: reason, unmeasured: unmeasured(assessment.unmeasured, point.record))
  end

  def unmeasured(keys, record)
    keys.map { |key| "#{Impact::FACTS.fetch(key)[:label]} (#{record.public_send(:"#{key}_source")})" }
  end

  def barriers(point)
    record = point.record
    energy = point.assessment.energy
    point.assessment.verdicts.map do |verdict|
      BarrierRow.new(
        name: verdict.barrier.name,
        rating: rating(verdict.rating),
        deflection: QuantityFormat.amount(verdict.barrier.deflection_mm, "mm"),
        verdict: verdict.kind.to_s,
        reason: verdict_reason(verdict, energy, record),
        unmeasured: unmeasured(verdict.unmeasured, record)
      )
    end
  end

  def rating(rating)
    rating && "#{QuantityFormat.amount(rating.joules, 'J')} at #{QuantityFormat.amount(rating.angle_deg, '°')}"
  end

  def verdict_reason(verdict, energy, record)
    case verdict.kind
    when :not_rated then UNRATED_REASONS.fetch(verdict.reason)
    when :too_weak then "#{QuantityFormat.amount(verdict.rating.joules, 'J')} is below #{QuantityFormat.amount(energy.joules, 'J')}"
    when :check_space then "clearance not given"
    when :does_not_fit
      "deflects #{QuantityFormat.amount(verdict.barrier.deflection_mm, 'mm')}, #{QuantityFormat.amount(record.clearance_mm, 'mm')} free"
    end
  end

  # "maximum load not given", "a and b not given", "a, b and c not given".
  def missing(keys)
    return nil if keys.empty?

    labels = keys.map { Impact::FACTS.fetch(_1)[:label] }
    "#{labels.size > 1 ? "#{labels[0...-1].join(', ')} and #{labels.last}" : labels.first} not given"
  end
end
