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
    invitations = user.group_invitations.where(:group_id => id)
    if !private? || invitations.present?
      invitations.destroy_all
      members << user unless user.groups.exists?(id)
    end
  end

  def has_member?(user)
    return false if user.nil?
    user.groups.exists?(id)
  end

  private
  def add_owner_to_members
    self.members << owner
  end

  def create_invitations
    return true if invitation_emails.blank?
    existing_invitations = invitations.where(['email IN (?)', invitation_emails.split(",").collect(&:strip)])
    existing_invitations.each {|i| i.send(:send_email)}    
    new_emails = (invitation_emails.split(",").collect(&:strip) - existing_invitations.collect(&:email)).reject(&:blank?).uniq
    new_emails.each {|e| invitations.create(:email => e.strip, :inviter_id => inviter_id || user_id)}
  end
  
  def valid_invitation_emails
    return true if invitation_emails.blank?
    unless invitation_emails.split(",").reject(&:blank?).uniq.all? {|e| e.strip.valid_email?}
      errors.add(:invitation_emails, 'make sure emails are valid and separated by commas')
    end
  end
  
end