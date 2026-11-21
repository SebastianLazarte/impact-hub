# frozen_string_literal: true

require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  def inertia_page
    script = Nokogiri::HTML(response.body).at_css("script[data-page]")
    assert script, "expected an Inertia page payload in the HTML"
    JSON.parse(script.text)
  end

  def step_named(page, name)
    page.dig("props", "steps").find { |s| s["name"] == name } || flunk("no step named #{name}")
  end

  test "IH-8: the home page renders the home/index Inertia component" do
    get root_path

    assert_response :success
    assert_equal "home/index", inertia_page["component"]
  end

  test "IH-8: each sample step carries the rule-computed score" do
    get root_path
    step = step_named(inertia_page, "Approve a customer credit limit")

    assert_equal "human", step["method"]
    assert_equal "approve", step["control"]
    assert_equal 25, step.dig("score", "value")
  end

  test "IH-8: hours travel as decimal strings, never JSON floats" do
    get root_path
    hours = step_named(inertia_page, "Copy order lines from email into the ERP")["hours"]

    assert_equal "32.00", hours["value"]
    assert_nil hours["reason"]
  end

  test "IH-8: unknown hours are sent as null with the reason" do
    get root_path
    hours = step_named(inertia_page, "Summarise installer site reports")["hours"]

    assert_nil hours["value"]
    assert_equal "runs per month not given", hours["reason"]
  end
end
