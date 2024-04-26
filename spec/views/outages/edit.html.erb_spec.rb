require 'rails_helper'

RSpec.describe "outages/edit", type: :view do
  let(:outage) {
    Outage.create!(
      eid: "MyString",
      device_lat: 1.5,
      device_lng: 1.5,
      customers_affected: 1,
      cause: "MyString",
      jurisdiction: "MyString",
      convex_hull: "",
      attempts: 1
    )
  }

  before(:each) do
    assign(:outage, outage)
  end

  it "renders the edit outage form" do
    render

    assert_select "form[action=?][method=?]", outage_path(outage), "post" do

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
