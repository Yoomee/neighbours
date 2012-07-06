module OtherNeighbourhoodForm
  
  include YmEnquiries::EnquiryForm
  
  title "Contact Us"
  
  intro "We're not available in your neighbourhood yet.  We'll contact you as soon as we are.  If you need more information, please contact us."
  
  fields :first_name, :last_name, :email, :message
  
  validates :message, :presence => {:message => "what do you want to know?"}
  validates :email, :email => true, :allow_blank => true
  
  email_from Settings.site_email
  email_subject "New feedback on #{Settings.site_name}"
  email_to Settings.admin_email

  response_message "Thanks a lot for getting in touch, we really appreciate it!"
  
end