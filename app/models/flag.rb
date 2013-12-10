class Flag < ActiveRecord::Base
  
  include YmCore::Model
  include Rails.application.routes.url_helpers
  
  belongs_to :user
  belongs_to :resource, :polymorphic => true
  
  validates_presence_of :user

  self.per_page = 10

  default_scope where(:removed_at => nil)

  scope :unresolved, where(:resolved_at => nil)
  scope :unremoved_needs, joins("LEFT OUTER JOIN needs ON (flags.resource_type = 'Need' AND flags.resource_id = needs.id)").where('needs.id IS NULL OR needs.removed = 0')

  def resource_description
    if resource.respond_to?(:description)
      resource.description
    elsif resource.respond_to?(:text)
      resource.text
    end
  end

  def resource_name
    case resource_type
    when 'Need'
      "#{resource.user}'s request"
    when 'GeneralOffer'
      "#{resource.user}'s offer"
    when 'Post'
      "#{resource.user}'s post"
    when 'Message'
      "#{resource.user}'s message"
    else
      resource.to_s
    end
  end
  
  def resource_url
    return nil if resource.nil?
    url_options = ActionMailer::Base.default_url_options
    resource_type == 'Post' ? group_post_url(resource.target, resource, url_options) : polymorphic_url(resource, url_options)
  end
  
end