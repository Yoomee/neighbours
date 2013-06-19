module UserConcerns::Validations
  
  def self.included(base)
    base.validates :postcode, :postcode => true, :presence => true
    base.validates :validation_code, :uniqueness => true    
    base.validate :dob_or_undiclosed_age, :over_16, :unless => :pre_registration?
    base.validates_confirmation_of :email, :message => "these don't match", :unless => :pre_registration?
    base.validates_confirmation_of :password, :message => "these don't match", :unless => :pre_registration?

    base.validates :email_confirmation, :presence => true, :if => :who_you_are_step?
    base.validates :password_confirmation, :presence => {:if => Proc.new{|u| u.who_you_are_step? && u.password.blank?}}    
    
    base.validates :house_number, :street_name, :city, :presence => true, :if => :where_you_live_step?

    base.validates :validate_by, :presence => true, :if => :validation_step?
    base.validates :agreed_conditions, :inclusion => { :in => [true], :if => :validation_step?, :message => "You must accept our terms and conditions to continue" }
    base.validates :card_type, :card_number, :card_expiry_date, :card_security_code, :presence => true, :if => :validation_step_with_credit_card?
    base.validates :card_type, :inclusion => {:in => User::CARD_TYPES}, :allow_blank => true, :if => :validation_step_with_credit_card?
    base.validates :card_number, :length => {:is => 16}, :numericality => true, :allow_blank => true, :if => :validation_step_with_credit_card?
    base.validates :card_security_code, :length => {:is => 3}, :numericality => true, :allow_blank => true, :if => :validation_step_with_credit_card?
    base.validates :card_expiry_date, :format => {:with => /\d{2}\/\d{4}/}, :allow_blank => true, :if => :validation_step_with_credit_card?
    base.validates :organisation_name, :presence => true, :if => :validation_step_with_organisation?
    
    base.before_validation :insert_space_into_postcode_if_needed
    base.after_validation :allow_non_unique_email_if_deleted
  end  
  
  def who_you_are_step?
    !pre_registration? && current_step == "who_you_are"
  end

  def where_you_live_step?
    current_step == "where_you_live"
  end
  
  def validation_step_with_credit_card?
    validation_step? && validate_by == "credit_card"
  end
  
  def validation_step?
    current_step == "validate"
  end

  def validation_step_with_organisation?
    validation_step? && validate_by == "organisation"
  end  
  
  private
  def add_errors_to_confirmation_fields
    return true if !who_you_are_step?
    [:email, :password].each do |attr_name|
      if errors[attr_name].any? {|m| m.match(/match/)}
        errors.add("#{attr_name}_confirmation", errors[attr_name].detect {|m| m.match(/match/)})
      end
    end
  end

  def add_password_errors_for_who_you_are_step
    return true if !who_you_are_step?
    if errors.present?
      errors.add(:password, "enter a password") unless errors[:password].present?
      errors.add(:password_confirmation, "enter a password") unless errors[:password_confirmation].present?
    end
  end
  
  def allow_non_unique_email_if_deleted
    return true if errors.messages.blank? || (email_errors_messages = errors.messages.delete(:email)).blank?
    non_unique_message = I18n.t("activerecord.errors.models.user.attributes.email.taken")
    if email_errors_messages.delete(non_unique_message) && User.exists?(:email => email, :is_deleted => false)
      email_errors_messages << non_unique_message
    end
    email_errors_messages.each do |message|
      self.errors.add(:email,message)
    end
  end
  
  def dob_or_undiclosed_age
    dob.present? || undisclosed_age?
  end  
  
  def insert_space_into_postcode_if_needed
    if postcode.present? && postcode.strip.split.size == 1
      (postcode.strip.length - 1).times do |num|
        postcode_with_space = postcode.dup.insert(num + 1, ' ')
        if postcode_with_space.upcase =~ PostcodeValidator::POSTCODE_FORMAT
          self.postcode = postcode_with_space
          break
        end
      end
    end
  end  
  
  def over_16
    return true if undisclosed_age? || admin?
    errors.add(:dob, "You must be over 16 to register") unless dob.present? && dob < 16.years.ago.to_date
  end  
  
end