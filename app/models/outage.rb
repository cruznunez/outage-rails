class Outage < ApplicationRecord
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
    minutes = (seconds / 60).to_i
    hours = (seconds / (60 * 60)).to_i
    out = ""
    out << "#{hours}hf" if hours.positive?
    out << "#{minutes}m" if minutes.positive?

    out
  end
end
