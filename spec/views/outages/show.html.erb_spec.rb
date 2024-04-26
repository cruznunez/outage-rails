require 'rails_helper'

RSpec.describe "outages/show", type: :view do
  before(:each) do
    assign(:outage, Outage.create!(
      eid: "Eid",
      device_lat: 2.5,
      device_lng: 3.5,
      customers_affected: 4,
      cause: "Cause",
      jurisdiction: "Jurisdiction",
      convex_hull: "",
      attempts: 5
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Eid/)
    expect(rendered).to match(/2.5/)
    expect(rendered).to match(/3.5/)
    expect(rendered).to match(/4/)
    expect(rendered).to match(/Cause/)
    expect(rendered).to match(/Jurisdiction/)
    expect(rendered).to match(//)
    expect(rendered).to match(/5/)
  end
end
