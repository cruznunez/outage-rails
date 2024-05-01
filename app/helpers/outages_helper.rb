module OutagesHelper
  def outages_hash(outages)
    output = []

    outages.each do |outage|
      output << {
        customers: outage.customers_affected,
        lat: outage.device_lat,
        lng: outage.device_lng,
        convex_hull: outage.convex_hull,
        cause: outage.cause.titleize
      }
    end

    output.to_json.html_safe
  end
end
