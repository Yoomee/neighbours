module ShareHelper

  def facebook_share(options = {})
    share_params = {
      :app_id => Settings.facebook_app_id,
      :link => request.url,
      :redirect_uri => request.url,
      :name => "Name",
      :description => strip_tags(options[:share_text].presence || object.text).truncate(150)
    }
    # if object.image.present?
    #   share_params[:picture] = "#{Settings.site_url}/#{object.image.thumb("400x").url}"
    # end
    link_to(content_tag(:i, '', :class => 'icon-facebook-sign'), "https://www.facebook.com/dialog/feed?#{share_params.to_query}", :target => "_blank", :rel => 'tooltip', :id => "facebook_share_link", :data => {:title => "Share on Facebook", :placement => 'left'})
  end

  def twitter_share()
    link_to(content_tag(:i, '', :class => 'icon-twitter-sign'), "https://twitter.com/intent/tweet?url=#{request.url}", :target => "_blank", :rel => 'tooltip', :id => "twitter_share_link", :data => {:title => "Share on Twitter", :placement => 'left'})
  end

end
