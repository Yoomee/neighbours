class Group < ActiveRecord::Base

  belongs_to :owner, :class_name => 'User', :foreign_key => 'user_id'
  has_many :posts, :as => :target, :dependent => :destroy
  has_and_belongs_to_many :members, :class_name => 'User', :uniq => true
  has_many :invitations, :class_name => 'GroupInvitation'
  
  after_create :add_owner_to_members
  after_save :create_invitations
  
  image_accessor :image
  attr_accessor :invitation_emails, :inviter_id
  
  validates :name, :description, :owner, :presence => true
  validates_property :format, :of => :image, :in => [:jpeg, :jpg, :png, :gif], :case_sensitive => false, :message => "must be an image"
  validate :valid_invitation_emails

  def add_member!(user)
    user.group_invitations.where(:group_id => id).destroy_all
    members << user unless user.groups.exists?(id)
  end

  def has_member?(user)
    user.groups.exists?(id)
  end

  private
  def add_owner_to_members
    self.members << owner
  end

  def create_invitations
    return true if invitation_emails.blank?
    emails = (invitation_emails.split(",").collect(&:strip) - invitations.collect(&:email)).compact
    emails.each {|e| invitations.create(:email => e.strip, :inviter_id => inviter_id || user_id)}
  end
  
  def valid_invitation_emails
    return true if invitation_emails.blank?
    unless invitation_emails.split(",").compact.all? {|e| e.strip.valid_email?}
      errors.add(:invitation_emails, 'make sure emails are valid and separated by commas')
    end
  end
  
end