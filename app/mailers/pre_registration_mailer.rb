class PreRegistrationMailer < ActionMailer::Base
  
  helper YmCore::UrlHelper
  helper YmSnippets::SnippetsHelper
  
  default :from => "site@neighbourscanhelp.org.uk",
          :bcc => ["developers@yoomee.com", "andy@yoomee.com"]

  def custom_email(pre_registration, subject, content)
    @pre_registration = pre_registration
    @content = content
    mail(:to => pre_registration.email, :subject => "[Neighbours Can Help] #{subject}")
  end
  
end