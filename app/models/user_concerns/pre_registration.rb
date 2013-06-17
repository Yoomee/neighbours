module UserConcerns::PreRegistration
  
  def self.included(base)
    base.before_validation :generate_password, :if => :pre_registration?
    base.before_validation :clean_up_needs_and_general_offers, :on => :create    
    base.validates :full_name, :presence => true
    base.send(:attr_accessor, :pre_register_need_or_offer)
    base.send(:boolean_accessor, :ready_for_pre_register_signup)
  end
  
  def pre_registration?
    role == 'pre_registration'
  end
  
  def pre_register_need_or_offer_valid?
    return true if pre_register_need_or_offer.blank?
    if pre_register_need_or_offer == 'need' && new_need = needs.first
      new_need.user = self
      new_need.valid?
    elsif pre_register_need_or_offer == 'general_offer' && new_general_offer = general_offers.first
      new_general_offer.user = self
      new_general_offer.valid?
    end
  end
  
  private  
  def clean_up_needs_and_general_offers
    general_offers(true) unless pre_register_need_or_offer == 'general_offer'
    needs(true) unless pre_register_need_or_offer == 'need'
  end
  
  def generate_password
    self.password ||= SecureRandom.hex(8)
  end
  
end