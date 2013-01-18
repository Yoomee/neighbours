module ShareHelper

  def facebook_share(options = {})
    share_params = {
      :app_id => Settings.facebook_app_id,
      :link => request.url,
      :redirect_uri => request.url,
      :name => "We have users in your area, but need more before we can launch",
      :description => strip_tags(options[:share_text].presence || object.text).truncate(150)
    }
    # share_params[:picture] = "#{Settings.site_url}/assets/person.png"
    
    link_to(content_tag("i", "Share on Facebook", :class => 'icon-facebook'), "https://www.facebook.com/dialog/feed?#{share_params.to_query}", :target => "_blank", :rel => 'tooltip', :id => "facebook_share_link", :data => {:title => "Share on Facebook", :placement => 'left'})
  end

  def twitter_share()
    link_to(content_tag(:i, '', :class => 'icon-twitter-sign'), "https://twitter.com/intent/tweet?url=#{request.url}&text=abc", :target => "_blank", :rel => 'tooltip', :id => "twitter_share_link", :data => {:title => "Share on Twitter", :placement => 'left'})
  end

end
