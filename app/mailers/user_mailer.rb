class UserMailer < ActionMailer::Base
  
  helper YmCore::UrlHelper
  
  default :from => "site@neighbourscanhelp.org.uk",
          :bcc => ["developers@yoomee.com", "andy@yoomee.com"]

  def new_flag(flag)
    @flag = flag
    @need = @flag.resource
    mail(:to => Settings.admin_email, :subject => "[Neighbours Can Help] Inappropriate content has been reported")
  end
          
  def new_comment(comment)
    @comment = comment
    @need = @comment.post.target
    @user = @comment.user == @comment.post.user ? @need.user : @comment.post.user
    mail(:to => @user.email, :subject => "[Neighbours Can Help] New comment from #{@comment.user}")
  end
  
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
    
  def validated(user)
    @user = user
    mail(:to => @user.email, :subject => "[Neighbours Can Help] You have been validated")
  end
  
end