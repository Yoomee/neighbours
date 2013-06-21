class Group < ActiveRecord::Base

  belongs_to :owner, :class_name => 'User', :foreign_key => 'user_id'
  has_many :posts, :as => :target, :dependent => :destroy
  has_and_belongs_to_many :members, :class_name => 'User', :uniq => true
  has_many :invitations, :class_name => 'GroupInvitation', :dependent => :destroy
  has_many :photos, :dependent => :destroy
  
  after_create :add_owner_to_members
  after_create :email_admins
  after_save :create_invitations
  
  image_accessor :image
  attr_writer :invitation_emails
  attr_accessor :inviter_id
  
  validates :name, :description, :owner, :presence => true
  validates_property :format, :of => :image, :in => [:jpeg, :jpg, :png, :gif], :case_sensitive => false, :message => "must be an image"
  validate :valid_invitation_emails

  default_scope where(:deleted_at => nil)

  scope :not_private, where(:private => false)
  scope :most_members, joins(:members).group('groups.id').select('groups.*, COUNT(users.id) AS member_count').order('member_count DESC')

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

  def invitation_emails
    @invitation_emails ||= []
  end

  def invitation_emails_s=(value)
    self.invitation_emails = value.to_s.split(",").reject(&:blank?).collect(&:strip).uniq
  end
  
  def invitation_emails_s
    invitation_emails.join(", ")
  end

  private
  def add_owner_to_members
    self.members << owner
  end

  def create_invitations
    return true if invitation_emails.blank?
    existing_invitations = invitations.where(['email IN (?)', invitation_emails])
    existing_invitations.each {|i| i.send(:send_email)}    
    new_emails = invitation_emails - existing_invitations.collect(&:email)
    new_emails.each {|e| invitations.create(:email => e.strip, :inviter_id => inviter_id || user_id)}
  end

  def email_admins
    UserMailer.new_group(self).deliver
  end

  def valid_invitation_emails
    return true if invitation_emails.empty?
    unless invitation_emails.all?(&:valid_email?)
      errors.add(:invitation_emails_s, 'make sure emails are valid and separated by commas')
    end
  end
  
end