require 'rails_helper'

RSpec.describe "outages/index", type: :view do
  before(:each) do
    assign(:outages, [
      Outage.create!(
        eid: "Eid",
        device_lat: 2.5,
        device_lng: 3.5,
        customers_affected: 4,
        cause: "Cause",
        jurisdiction: "Jurisdiction",
        convex_hull: "",
        attempts: 5
      ),
      Outage.create!(
        eid: "Eid",
        device_lat: 2.5,
        device_lng: 3.5,
        customers_affected: 4,
        cause: "Cause",
        jurisdiction: "Jurisdiction",
        convex_hull: "",
        attempts: 5
      )
    ])
  end

  it "renders a list of outages" do
    render
    cell_selector = Rails::VERSION::STRING >= '7' ? 'div>p' : 'tr>td'
    assert_select cell_selector, text: Regexp.new("Eid".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(2.5.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(3.5.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(4.to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Cause".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Jurisdiction".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(5.to_s), count: 2
  end
end
