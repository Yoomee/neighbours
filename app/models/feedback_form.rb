module FeedbackForm
  
  include YmEnquiries::EnquiryForm
  
  title "Contact Us"
  
  intro "We are currently in beta - which means we've released our new online community before it's finished. Why did we do that? There's a very simple answer: we want to get feedback from you, the community, during the development process rather than afterwards.<br /><br />And we sincerely appreciate your constructive comments! So don't be shy, use the form below and tell us what you think! Then we'll build our new online platform together."
  
  fields :first_name, :last_name, :email, :message
  
  validates :message, :presence => {:message => "please tell us what you think"}
  validates :email, :email => true, :allow_blank => true
  
  email_from Settings.site_email
  email_subject "New feedback on #{Settings.site_name}"
  email_to Settings.admin_email

  response_message "Thanks a lot for your feedback, we really appreciate it!"
  
end