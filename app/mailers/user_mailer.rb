class UserMailer < ActionMailer::Base
  
  helper YmCore::UrlHelper
  helper YmSnippets::SnippetsHelper
  
  default :from => "site@neighbourscanhelp.org.uk",
          :bcc => ["developers@yoomee.com", "andy@yoomee.com"]

  def custom_email(user, subject, content)
    @user = user
    @content = content
    mail(:to => user.email, :subject => "[Neighbours Can Help] #{subject}")
  end

  def complete_group_registration(user)
    @user = user
    mail(:to => user.email, :subject => "[Neighbours Can Help] Join a group")
  end

  def new_flag(flag)
    @flag = flag
    mail(:to => Settings.admin_email, :subject => "[Neighbours Can Help] Inappropriate content has been reported")
  end
          
  def new_comment(comment, user)
    @comment = comment
    @user = user
    @resource_url = @comment.post.target.is_a?(Need) ? need_url(@comment.post.target) : group_url(@comment.post.target)
    return true if @user.no_notifications?
    mail(:to => @user.email, :subject => "[Neighbours Can Help] New comment from #{@user}")
  end
  
  def new_offer(offer)
    @offer = offer
    @user = @offer.need.user
    return true if @user.no_notifications?
    mail(:to => @user.email, :subject => "[Neighbours Can Help] #{@offer.user} has offered to help you")
  end
  
  def accepted_offer(offer)
    @offer = offer
    @user = @offer.user
    return true if @user.no_notifications?
    mail(:to => @user.email, :subject => "[Neighbours Can Help] #{@offer.need.user} has accepted your offer of help")
  end
    
  def validated(user)
    @user = user
    mail(:to => @user.email, :subject => "[Neighbours Can Help] You have been validated")
  end
  
  def send_invite(from, to, message)
     @message = message
     mail(:from => from, :to => to, :subject => "Your personal invite to Neighbours Can Help")
  end
  
  def pre_register_thank_you(pre_register_user)
    @pre_register_user = pre_register_user
    mail(:to => @pre_register_user.email, :subject => "[Neighbours Can Help] Thank you for pre-registering")
  end
  
  def admin_message(subject, message, hash)
    @message = message
    @hash = hash
    mail(:to => Settings.admin_email, :subject => "[Neighbours Can Help] #{subject}")   
  end
  
  def new_registration(user)
    @user = user
    mail(:to => @user.email, :subject => "[Neighbours Can Help] Thank you for registering")
  end
  
  def community_champion_request(user)
    @user = user
    mail(:to => Settings.admin_email, :subject => "[Neighbours Can Help] Neighbourhood champion request")
  end  
  
  def group_invitation(group_invitation)
    @group_invitation = group_invitation
    @user = @group_invitation.user
    mail(:to => group_invitation.email, :bcc => Settings.admin_email, :subject => "[Neighbours Can Help] Join #{group_invitation.group}")
  end

  def new_group(group)
    @group = group
    mail(:to => Settings.admin_email, :subject => "[Neighbours Can Help] New group")
  end

  def new_group_member(group, member, options = {})
    @group, @member = group, member
    @admin_email = options[:admin_email]
    mail(:to => (@admin_email ? Settings.admin_email : group.owner.email), :subject => "[Neighbours Can Help] #{member} joined #{group}")
  end

  def new_group_post(post)
    @member = post.user
    @group = post.target
    mail(:to => @group.owner.email, :subject => "[Neighbours Can Help] #{@member} posted in #{@group}")
  end

end