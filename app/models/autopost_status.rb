class AutopostStatus < ActiveRecord::Base
  belongs_to :autopostable, :polymorphic => true
  validates :autopostable, :provider, :status, :presence => true 
  
  %w{unauthorised redirected asked_for_pages failed pending queued posted}.each do |status_s|
    scope status_s, where(:status => status_s)
    define_method("#{status_s}?") do
      status == status_s
    end
  end
  
  scope :redirected_or_asked_for_pages, where("status = 'redirected' OR status = 'asked_for_pages'")
  
  %w{facebook twitter}.each do |provider_s|
    scope provider_s, where(:provider => provider_s)
    define_method("#{provider_s}?") do
      provider == provider_s
    end
  end
  
  def auth_params
    {}.tap do |params|
      params[:provider] = provider
      if facebook?
        params[:scope] = "email,publish_stream,manage_pages,user_photos"
      elsif twitter?
        params[:x_auth_access_type] = "write"
      end
    end
  end
  
  
end