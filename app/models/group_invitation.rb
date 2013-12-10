class GroupInvitation < ActiveRecord::Base

  belongs_to :group
  belongs_to :user
  belongs_to :inviter, :class_name => 'User'

  validates :group, :presence => true
  validates :email, :email => true, :presence => {:unless => :user}, :allow_blank => true

  default_scope where(:removed_at => nil)
  
  before_create :generate_ref
  after_create :send_email
  
  def email=(value)
    self.user = User.find_by_email(value)
    write_attribute(:email, value)
  end
  
  def email
    read_attribute(:email).presence || user.try(:email)
  end
  
  private
  def generate_ref
    self.ref = SecureRandom.hex(8)
  end

  def send_email
    UserMailer.group_invitation(self).deliver
  end

end