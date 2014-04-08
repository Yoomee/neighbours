class Organisation < ActiveRecord::Base
  include YmCore::Model

  belongs_to :admin, :class_name => 'User'

  validates :name, :presence => true, :uniqueness => true

  class << self

    def valid
      Organisation.joins(:admin).where('users.validated = 1') + Organisation.where(:admin_id => nil)
    end

  end
end