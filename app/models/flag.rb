class Flag < ActiveRecord::Base
  
  include YmCore::Model
  
  belongs_to :user
  belongs_to :resource, :polymorphic => true
  
  validates_presence_of :user
  
end