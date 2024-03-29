module UserConcerns::Validations
  
  def self.included(base)
    base.validates :postcode, :postcode => true, :presence => true
    base.validates :validation_code, :uniqueness => true    
    base.validate :dob_or_undiclosed_age, :over_16, :unless => [:pre_registration?, :pre_registered_organisation?]
    base.validates_confirmation_of :email, :message => "these don't match", :if => [:who_you_are_step?, :group_user?, :new_record?]
    base.validates_confirmation_of :password, :message => "these don't match", :unless => [:pre_registration?, :pre_registered_organisation?]
    base.validate :group_invitation_email_matches, :on => :create

    base.validates :email_confirmation, :presence => true, :if => [:who_you_are_step?, :group_user?, :new_record?]
    base.validates :password_confirmation, :presence => {:if => Proc.new{|u| u.group_user? && u.password.blank? && u.new_record?}}
    
    base.validates :house_number, :street_name, :city, :presence => true, :if => :where_you_live_step?

    base.validates :validate_by, :presence => {:if => :validation_step?, :message => "Please click on one of the options below"}
    base.validate :agreed_conditions

    base.validates :organisation_id, :presence => true, :if => :validation_step_with_organisation?

    base.validate :preauth_credit_card, :if => :validation_step?
    
    base.before_validation :insert_space_into_postcode_if_needed
    base.after_validation :add_errors_to_confirmation_fields, :add_password_errors_for_who_you_are_step
  end  
  
  def who_you_are_step?
    (!pre_registration? || !pre_registered_organisation?) && current_step == "who_you_are"
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
    validation_step? && validate_by == "organisation" && organisation_as_admin.nil?
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
    return true unless (who_you_are_step? && group_user? && new_record?)
    if errors.present?
      errors.add(:password, "enter a password") unless errors[:password].present?
      errors.add(:password_confirmation, "enter a password") unless errors[:password_confirmation].present?
    end
  end

  def agreed_conditions
    if validation_step? || group_user?
      if read_attribute(:agreed_conditions) == true
        return true
      else
        errors.add(:agreed_conditions, "You must accept our terms and conditions and privacy policy to continue")
      end
    end
  end
  
  def credit_card_valid?
    credit_card.name = full_name
    card_valid = credit_card.valid?
    if !credit_card.brand.in?(CreditCardPreauth::ACCEPTED_CARDS.values)
      credit_card.errors.add(:brand, "please select an accepted card type")
      card_valid = false
    end
    errors.add(:credit_card, "card details are invalid") if !card_valid
    card_valid
  end
  
  def dob_or_undiclosed_age
    dob.present? || undisclosed_age? || is_organisation_admin?
  end  
  
  def group_invitation_email_matches
    return true if errors[:email].present? || seen_group_invitation_email_warning?
    if invitation = GroupInvitation.find_by_id(group_invitation_id)
      if invitation.group.private? && email != invitation.email
        errors.add(:email, "In order to join the group #{invitation.group}, you will need to sign up with the same email address that the invitation was sent to. Click 'Register' again to ignore this message and continue.")
        self.seen_group_invitation_email_warning = true
      end
    end
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
    return true if undisclosed_age? || admin? || is_organisation_admin?
    errors.add(:dob, "You must be over 16 to register") unless dob.present? && dob < 16.years.ago.to_date
  end  
  
  def preauth_credit_card
    if validate_by == 'credit_card' && credit_card_valid? && agreed_conditions?
      return true if credit_card_preauth.present?
      self.credit_card_preauth = CreditCardPreauth.create_from_user(self)
      credit_card_preauth.preauth!
      if credit_card_preauth.success?
        self.validated = true
      else
        errors.add(:credit_card_details, "Unfortunately we couldn't verify your address from the card details you entered. Please check your card details or select an alternative validation option.")
      end
    end
  end
  
end