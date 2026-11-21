# frozen_string_literal: true

class SurveysController < InertiaController
  def index
    render inertia: "surveys/index", props: SurveyListPageResource.new(Surveys::ListSurveys.call).serializable_hash
  end

  def show
    render inertia: "surveys/show", props: SurveyPageResource.new(Surveys::AssessSurvey.call(params[:id])).serializable_hash
  end
end
