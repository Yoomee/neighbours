module Autopostable
  
  def self.included(base)
    base.send(:include, Rails.application.routes.url_helpers)
    base.has_many :autopost_statuses, :as => :autopostable, :autosave => true, :dependent => :destroy
  end
  
  def autopost
    if Rails.env.production?
      autopost_statuses.pending.each do |autopost_status|
        autopost_status.update_attribute(:status, 'queued')
        post_to_provider(autopost_status.provider)
      end
    end
  end
  
  private
  def autopost_url
    polymorphic_url(self, ActionMailer::Base.default_url_options)
  end
  
  def prepare_for_autopost
    if user.validated? || self.is_a?(Group)
      autopost_statuses.build(:provider => "twitter", :status => "pending")
      autopost_statuses.build(:provider => "facebook", :status => "pending")
      return autopost_statuses
    end
  end
  
  def post_to_provider(provider)
    case provider.to_sym
    when :facebook then post_to_facebook
    when :twitter  then post_to_twitter
    end
  end
  handle_asynchronously :post_to_provider
  
  def post_to_facebook
    begin  
      options = {:link => autopost_url, :message => autopost_text}
      if self.is_a?(Group)
        options[:picture] = Settings.site_url + (image || default_image).thumb("400x400#").url
        options[:name] = name
        options[:description] = description
      end
      res = facebook_client.post("me/feed", nil, options)
      raise Exception if res["id"].blank?
      autopost_statuses.facebook.first.update_attribute(:status, 'posted')
    rescue Exception => e
      logger.error "Error posting to Facebook: #{e.message}"
      autopost_statuses.facebook.first.update_attribute(:status, 'failed')
    end
  end
  
  def facebook_client
    @facebook_client ||= Mogli::Client.new(Settings.facebook.site_page_access_token)
  end
  
  def post_to_twitter
    begin  
      twitter_client.update("#{autopost_text.truncate(100)} #{autopost_url}")
      autopost_statuses.twitter.first.update_attribute(:status, 'posted')
    rescue StandardError => e
      logger.error "Error posting to Twitter: #{e.message}"
      autopost_statuses.twitter.first.update_attribute(:status, 'failed')
    end
  end
  
  def twitter_client
    @twitter_client ||= Twitter::Client.new(
      :consumer_key => Settings.twitter.consumer_key,
      :consumer_secret => Settings.twitter.consumer_secret,
      :oauth_token => Settings.twitter.site_oauth_token,
      :oauth_token_secret => Settings.twitter.site_oauth_secret
    )
  end

end