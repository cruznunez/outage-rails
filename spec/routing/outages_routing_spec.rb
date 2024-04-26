require "rails_helper"

RSpec.describe OutagesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/outages").to route_to("outages#index")
    end

    it "routes to #new" do
      expect(get: "/outages/new").to route_to("outages#new")
    end

    it "routes to #show" do
      expect(get: "/outages/1").to route_to("outages#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/outages/1/edit").to route_to("outages#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/outages").to route_to("outages#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/outages/1").to route_to("outages#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/outages/1").to route_to("outages#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/outages/1").to route_to("outages#destroy", id: "1")
    end
  end
end
