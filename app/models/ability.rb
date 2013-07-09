# Don't delete comments! They are used in gems for adding abilities
class Ability
  
  include CanCan::Ability
  
  def initialize(user)
    
    # open ability
    can :create, Enquiry
    can :show, Page, :draft => false
    can :show, Need
    can [:show, :area, :about, :news, :help], Neighbourhood
    can [:read, :popular], Group
    can :create, Group
    can :read, GroupInvitation
    
    if user.try(:admin?)
      can :manage, :all
      can :validate, User  
      # admin ability
    elsif user
      # user ability
      can :show, MessageThread do |thread|
        thread.users.exists?(:id => user.id)
      end
      can :index, MessageThread
      can :new, Message      
      can :create, Message do |message|
        message.thread && (message.thread.users - [user] - Message.valid_recipients_for_user(user)).empty?
      end
      can [:create], Flag
      can [:create], Comment
      can [:show, :create], Post
      can [:update, :destroy], Post, :user_id => user.id
      can :read, User
      can :manage, User, :id => user.id     
      cannot :index, User
      can [:read, :search], Need
      can :update, Need, :user_id => user.id
      can [:create, :index, :read], Offer
      can [:accept, :reject], Offer do |offer|
        offer.need.user_id == user.id
      end
      can :create, Need
      cannot :new, Need
      can :create, GeneralOffer
      cannot :new, GeneralOffer
      if user.fully_registered?
        can :new, Need
        can :new, GeneralOffer        
        can [:create, :thanks, :accept], GeneralOffer
        can :read, GeneralOffer do |general_offer|
          (general_offer.user_id == user.id) || general_offer.user.validated?
        end
        can [:update, :destroy], GeneralOffer, :user_id => user.id
        cannot :accept, GeneralOffer do |general_offer|
          (general_offer.user_id == user.id) || !general_offer.user.validated?
        end
      end
      if user.is_community_champion?
        can :index, Post
      end
      # neighbourhood admin
      can [:manage], Need do |need|
        need.user.try(:neighbourhood).try(:admin_id) == user.id
      end
      can :index, :admin do
        user.is_neighbourhood_admin?
      end
      can [:manage], User do |u|
        u.try(:neighbourhood).try(:admin_id) == user.id
      end
      can [:manage], Page do |p|
        p.try(:neighbourhood).try(:admin_id) == user.id
      end
      can :new, Page do
        user.is_neighbourhood_admin?
      end
      can [:create, :join], Group
      can [:members], Group do |group|
        group.has_member?(user)
      end
      can [:update, :delete], Group do |g|
        g.user_id == user.id
      end
      can [:new, :create], GroupInvitation do |invitation|
        invitation.group.try(:user_id) == user.id || (invitation.group && invitation.group.has_member?(user))
      end
      can :create, GroupRequest
      can [:new, :create, :read], Photo do |photo|
        photo.group.has_member?(user)
      end
    end
    
  end
  
end
