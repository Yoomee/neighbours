class Flag < ActiveRecord::Base
  
  include YmCore::Model
  
  belongs_to :user
  belongs_to :resource, :polymorphic => true
  
  validates_presence_of :user

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
  
end