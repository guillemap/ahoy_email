module AhoyEmail
  class DatabaseSubscriber
    def track_send(event)
      # use has_history to store on Ahoy::Messages
    end

    def track_open(event)
      Ahoy::Open.find_or_create_by!(campaign: event[:campaign], token: event[:token])
    end

    def track_click(event)
      Ahoy::Click.create!(campaign: event[:campaign], token: event[:token])
    end

    def stats(campaign)
      sends = Ahoy::Message.where(campaign: campaign).count

      if defined?(ActiveRecord) && Ahoy::Open < ActiveRecord::Base
        result = Ahoy::Open.where(campaign: campaign).select("COUNT(*) AS opens, COUNT(DISTINCT token) AS unique_opens").to_a[0]
        opens = result.opens
      else
        opens = Ahoy::Open.where(campaign: campaign).count
      end

      if defined?(ActiveRecord) && Ahoy::Click < ActiveRecord::Base
        result = Ahoy::Click.where(campaign: campaign).select("COUNT(*) AS clicks, COUNT(DISTINCT token) AS unique_clicks").to_a[0]
        clicks = result.clicks
        unique_clicks = result.unique_clicks
      else
        clicks = Ahoy::Click.where(campaign: campaign).count
        # TODO use aggregation framework
        unique_clicks = Ahoy::Click.where(campaign: campaign).distinct(:token).count
      end

      if sends > 0 || clicks > 0
        {
          sends: sends,
          clicks: clicks,
          unique_clicks: unique_clicks,
          ctr: 100 * unique_clicks / sends.to_f,
          opens: opens,
          open_rate: 100 * opens / sends.to_f
        }
      end
    end

    def campaigns
      if defined?(ActiveRecord) && Ahoy::Message < ActiveRecord::Base
        Ahoy::Message.where.not(campaign: nil).distinct.pluck(:campaign)
      else
        Ahoy::Message.where(campaign: {"$ne" => nil}).distinct(:campaign)
      end
    end
  end
end
