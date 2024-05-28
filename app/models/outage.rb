class Outage < ApplicationRecord
  unless ActiveRecord::Base.connection.adapter_name == 'SQLite'
    self.table_name = "outage_tracker" unless
    alias_attribute :eid, :outage_identifer
    alias_attribute :device_lng, :device_lon
    alias_attribute :customers_affected, :affected
    alias_attribute :started_at, :outage_start_estimate
    alias_attribute :ended_at, :outage_end_estimate
    alias_attribute :requests, :nil?
  end

  def start
    if started_at.to_date == Date.today
      started_at.strftime('%l:%M%P')
    else
      started_at.strftime('%b %e %l:%M%P')
    end
  end

  def end
    return unless ended_at?
    if ended_at.to_date == Date.today
      ended_at.strftime('%l:%M%P')
    else
      started_at.strftime('%b %e %l:%M%P')
    end
  end

  def restoration_time
    return unless ended_at?
    seconds = ended_at - started_at
    hours = (seconds / (60 * 60)).to_i
    minutes = (seconds % 60).to_i
    out = ""
    out << "#{hours}h" if hours.positive?
    out << "#{minutes}m" if minutes.positive?

    out
  end

  def self.sqlite?
    ActiveRecord::Base.connection.adapter_name == 'SQLite'
  end
end
