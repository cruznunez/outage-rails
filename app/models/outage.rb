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
    minutes = (seconds / 60 % 60).to_i
    out = ""
    out << "#{hours}h" if hours.positive?
    out << "#{minutes}m" if minutes.positive?

    out
  end

  def self.format_duration(seconds)
    return "N/A" if seconds.nil?
    minutes = (seconds / 60).to_i
    hours = minutes / 60
    minutes = minutes % 60
    formatted_duration = ""
    formatted_duration += "#{hours}h" if hours > 0
    formatted_duration += "#{minutes}m" if minutes > 0 || hours == 0
    formatted_duration
  end

  def self.sqlite?
    ActiveRecord::Base.connection.adapter_name == 'SQLite'
  end

  def self.average_restoration_time_by_fips
    select("block_fips, COUNT(*) AS outage_count, AVG(EXTRACT(EPOCH FROM (outage_end_estimate - outage_start_estimate))) AS avg_restoration_time")
      .where(outage_restored: true)
      .group(:block_fips)
      .order("avg_restoration_time DESC")
      # .map { |record| [record.block_fips, record.outage_count, format_duration(record.avg_restoration_time)] }
  end
end
