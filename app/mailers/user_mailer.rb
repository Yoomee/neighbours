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
    return true unless should_email?(@user)
    @comment, @user = comment, user
    @resource_url = @comment.post.target.is_a?(Need) ? need_url(@comment.post.target) : group_url(@comment.post.target)
    mail(:to => @user.email, :subject => "[Neighbours Can Help] New comment from #{@user}")
  end
  
  def new_offer(offer)
    @offer, @user = offer, offer.need.user
    return true unless should_email?(@user)
    mail(:to => @user.email, :subject => "[Neighbours Can Help] #{@offer.user} has offered to help you")
  end
  
  def accepted_offer(offer)
    @offer, @user = offer, offer.user
    return true unless should_email?(@user)
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
  
  def group_request(group_request)
    @group_request = group_request
    @group_owner = @group_request.group.owner
    return true unless should_email?(@group_owner)
    mail(:to => @group_owner.email, :subject => "[Neighbours Can Help] Someone has requested to join #{@group_request.group}")
  end
  
  def group_request_accepted(group_request)
    return true unless should_email?(group_request.user)
    @group_request = group_request
    mail(:to => @group_request.user.email, :subject => "[Neighbours Can Help] You're now a member of #{@group_request.group}")
  end

  def new_group(group)
    @group = group
    mail(:to => Settings.admin_email, :subject => "[Neighbours Can Help] New group")
  end

  def new_group_member(group, member, options = {})
    @group, @member = group, member
    @admin_email = options[:admin_email]
    return true unless options[:admin_email] || should_email?(@group.owner)
    mail(:to => (@admin_email ? Settings.admin_email : group.owner.email), :subject => "[Neighbours Can Help] #{member} joined #{group}")
  end

  def new_group_post(post)
    @member, @group = post.user, post.target
    return true unless should_email?(@group.owner)
    mail(:to => @group.owner.email, :subject => "[Neighbours Can Help] #{@member} posted in #{@group}")
  end

  def weekly_top_stats(options = {})
    @admin_email = options[:admin_email]
    mail(:to => @admin_email || Settings.admin_email, :subject => "[Neighbours Can Help] Weekly Top Stats")
  end

  private
  def should_email?(user)
    !user.is_deleted? && !user.no_notifications?
  end

end