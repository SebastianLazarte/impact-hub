# frozen_string_literal: true

class SurveysController < InertiaController
  def index
    render inertia: "surveys/index", props: SurveyListPageResource.new(Surveys::ListSurveys.call).serializable_hash
  end

  def new
    render inertia: "surveys/new", props: SurveyFormPageResource.new(Impact).serializable_hash
  end

  def create
    result = Surveys::CreateSurvey.call(survey_params)
    if result.success?
      redirect_to survey_path(result.value)
    else
      redirect_to new_survey_path, inertia: { errors: result.errors }
    end
  end

  def show
    render inertia: "surveys/show", props: SurveyPageResource.new(Surveys::AssessSurvey.call(params[:id])).serializable_hash
  end

  private

  def survey_params
    facts = Impact::FACTS.keys.flat_map { [ _1, :"#{_1}_source" ] }
    params.expect(survey: [ :site_name, :customer_name, :surveyed_on, :mode, :notes,
                            hazard_points: [ [ :name, :zone, :application, *facts ] ] ]).to_h
  end
end
