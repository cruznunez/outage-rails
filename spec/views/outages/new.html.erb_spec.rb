require 'rails_helper'

RSpec.describe "outages/new", type: :view do
  before(:each) do
    assign(:outage, Outage.new(
      eid: "MyString",
      device_lat: 1.5,
      device_lng: 1.5,
      customers_affected: 1,
      cause: "MyString",
      jurisdiction: "MyString",
      convex_hull: "",
      attempts: 1
    ))
  end

  it "renders new outage form" do
    render

    assert_select "form[action=?][method=?]", outages_path, "post" do

      assert_select "input[name=?]", "outage[eid]"

      assert_select "input[name=?]", "outage[device_lat]"

      assert_select "input[name=?]", "outage[device_lng]"

      assert_select "input[name=?]", "outage[customers_affected]"

      assert_select "input[name=?]", "outage[cause]"

      assert_select "input[name=?]", "outage[jurisdiction]"

      assert_select "input[name=?]", "outage[convex_hull]"

      assert_select "input[name=?]", "outage[attempts]"
    end
  end
end
