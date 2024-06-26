class FetchOutagesJob < ApplicationJob
  queue_as :default

  include ImporterLogic

  def perform(jurisdiction)
    start_up jurisdiction
    disable_button
    broadcast_count
    import_data
    print_results
    enable_button
  end

  def start_up(jurisdiction)
    @jurisdiction = jurisdiction
    @api = DukeAPI.new
    @start = Time.now
    @stream = 'outages'
    @total = 0
  end

  def import_data
    api_before = Time.now
    outages = @api.outages(@jurisdiction)['data']
    api_after = Time.now
    @api_time = api_after - api_before
    # first close any outages that are not in this dataset and that have not been closed
    outage_ids = outages.map { |o| o['sourceEventNumber'] }
    restored = Outage.where(ended_at: nil)
                     .where.not(eid: outage_ids)
    restored.update ended_at: Time.now
    broadcast_restorations

    # then, import the outages
    outages.each do |outage|
      eid = outage['sourceEventNumber']
      affected = outage['customersAffectedNumber']
      lat = outage['deviceLatitudeLocation']
      lng = outage['deviceLongitudeLocation']
      hull = outage['convexHull']
      cause = outage['outageCause']

      outage = Outage.find_or_initialize_by eid: eid
      persisted = outage.persisted?

      outage.eid = eid
      outage.device_lat = lat
      outage.device_lng = lng
      outage.customers_affected = affected
      outage.cause = cause
      outage.jurisdiction = @jurisdiction
      outage.convex_hull = hull
      outage.started_at = Time.now unless persisted
      outage.requests = outage.requests + 1

      outage.save
      broadcast_count unless persisted
      @total += 1
    end
  end

  def disable_button
    button = '<a id="btn" class="btn btn-primary is-invalid disabled" align="right" href="/outages/fetch">Wait</a>'
    broadcast_replace_to @stream, target: 'btn', html: button
  end

  def broadcast_restorations
    restorations = Outage.where.not(ended_at: nil)
    avg_time = restorations.sum { |o| o.ended_at - o.started_at } / restorations.count rescue 0
    hours = (avg_time / (60 * 60)).to_i
    minutes = (avg_time % 60).to_i
    avg_restore_time = ""
    avg_restore_time << "#{hours}h" if hours.positive?
    avg_restore_time << "#{minutes}m" if minutes.positive?
    avg_restore_time = avg_restore_time.presence || 0

    broadcast_update_to @stream, target: 'b', plain: restorations.count.to_fs(:delimited)
    broadcast_update_to @stream, target: 'c', plain: avg_restore_time
  end

  def broadcast_count
    active_outages = Outage.where(ended_at: nil).order(created_at: :desc)
    all_outages = Outage.order(created_at: :desc)
    broadcast_update_to @stream, target: 'a', plain: active_outages.count
    # broadcast_replace_to @stream, target: 'outages', partial: 'outages/outages', locals: { outages: all_outages }
    broadcast_replace_to @stream, target: 'outages', partial: 'outages/outages', locals: { outages: active_outages }
  end

  def enable_button
    button = '<a id="btn" class="btn btn-primary is-valid" align="right" href="/outages/fetch">Fetch</a>'
    broadcast_replace_to @stream, target: 'btn', html: button
  end
end
