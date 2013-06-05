class GroupInvitation < ActiveRecord::Base

  belongs_to :group
  belongs_to :user
  belongs_to :inviter, :class_name => 'User'

  validates :group, :presence => true
  validates :email, :email => true, :presence => {:unless => :user}, :allow_blank => true
  
  before_create :generate_ref
  
  def email=(value)
    self.user = User.find_by_email(value)
    write_attribute(:email, value)
  end
  
  def email
    read_attribute(:email).presence || user.email
  end
  
  private
  def generate_ref
    self.ref = SecureRandom.hex(8)
  end

end