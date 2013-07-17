class Group < ActiveRecord::Base

  include YmCore::Model
  include Autopostable

  belongs_to :owner, :class_name => 'User', :foreign_key => 'user_id'
  has_many :posts, :as => :target, :dependent => :destroy
  has_and_belongs_to_many :members, :class_name => 'User', :uniq => true, :conditions => {:is_deleted => false}
  has_many :invitations, :class_name => 'GroupInvitation', :dependent => :destroy
  has_many :requests, :class_name => 'GroupRequest', :dependent => :destroy
  has_many :photos, :dependent => :destroy
  
  image_accessor :image
  attr_writer :invitation_emails
  attr_accessor :inviter_id, :invitation_message
  
  alias_attribute :user, :owner
  
  validates :name, :description, :owner, :location, :lat, :lng, :presence => true
  validates_property :format, :of => :image, :in => [:jpeg, :jpg, :png, :gif], :case_sensitive => false, :message => "must be an image"
  validate :valid_invitation_emails, :geocodable_location

  geocoded_by :location_with_country, :latitude => :lat, :longitude => :lng

  before_validation :geocode, :if => :location_changed?
  before_create :prepare_for_autopost, :unless => :private?
  after_create :autopost, :unless => :private?
  after_create :add_owner_to_members
  after_create :email_admins
  after_save :create_invitations

  default_scope where(:deleted_at => nil)

  scope :not_private, where(:private => false)
  scope :most_members, joins(:members).group('groups.id').select('groups.*, COUNT(users.id) AS member_count').order('member_count DESC')

  define_index do
    indexes name
    has id
    has "RADIANS(lat)", :as => :latitude,  :type => :float
    has "RADIANS(lng)", :as => :longitude, :type => :float
    where "deleted_at IS NULL"    
    set_property :delta => true
  end

  class << self
    
    def closest_to(*args)
      options = args.extract_options!
      lat, lng = args.size == 1 ? [args[0].lat, args[0].lng] : args
      search({:geo => [(lat.to_f*Math::PI/180),(lng.to_f*Math::PI/180)], :order => "@geodist ASC"}.merge(options))
    end
    
  end

  def add_member!(user, force = false)
    return false unless force || can_join?(user)
    user.group_invitations.where(:group_id => id).destroy_all
    user.group_requests.where(:group_id => id).destroy_all
    members << user unless user.groups.exists?(id)
  end
  
  def autopost_text
    out = owner.neighbourhood ? "#{owner} from #{owner.neighbourhood}" : owner.to_s
    "#{out} has created a new group called #{name}"
  end

  def can_join?(user)
    return false if user.nil? || user.pre_registration?
    !private? || user.group_invitations.exists?(:group_id => id)
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

  def location_with_country
    "#{location}, UK"
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
    new_emails.each {|e| invitations.create(:email => e.strip, :inviter_id => inviter_id || user_id, :message => invitation_message)}
  end

  def email_admins
    UserMailer.new_group(self).deliver
  end
  
  def geocodable_location
    unless all_present?(:lat, :lng)
      self.errors.add(:location, "couldn't find location")
    end
  end

  def valid_invitation_emails
    return true if invitation_emails.empty?
    unless invitation_emails.all?(&:valid_email?)
      errors.add(:invitation_emails_s, 'make sure emails are valid and separated by commas')
    end
  end
  
end