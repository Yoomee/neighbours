class UserMailer < ActionMailer::Base
  
  helper YmCore::UrlHelper
  
  default :from => "site@neighbours.yoomee.com", 
          :bcc => ["developers@yoomee.com", "andy@yoomee.com"]
  
  def new_offer(offer)
    @offer = offer
    @user = @offer.need.user
    mail(:to => @user.email, :subject => "[Neighbours Can Help] #{@offer.user} has offered to help you")
  end
  
  def accepted_offer(offer)
    @offer = offer
    @user = @offer.user
    mail(:to => @user.email, :subject => "[Neighbours Can Help] #{@offer.need.user} has accepted your offer of help")
  end
  
end