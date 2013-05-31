# Don't delete comments! They are used in gems for adding abilities
class Ability
  
  include CanCan::Ability
  
  def initialize(user)
    
    # open ability
    can [:show, :create], PreRegistration
    can :create, Enquiry
    can :show, Page, :draft => false
    can [:show, :create], Need
    can [:show, :area, :about, :news, :help], Neighbourhood
    can :about, Group
    
    if user.try(:admin?)
      can :manage, :all
      can :validate, User  
      # admin ability
    elsif user
      # user ability
      can [:create], Flag
      can [:create], Comment
      can [:show, :create], Post
      can [:update, :destroy], Post, :user_id => user.id
      can :manage, User, :id => user.id     
      cannot :index, User
      can [:create, :read, :search], Need 
      can :update, Need, :user_id => user.id
      can [:create, :index, :read], Offer
      can [:accept, :reject], Offer do |offer|
        offer.need.user_id == user.id
      end
      can [:create, :thanks, :accept], GeneralOffer
      can :read, GeneralOffer do |general_offer|
        (general_offer.user_id == user.id) || general_offer.user.validated?
      end
      can [:update, :destroy], GeneralOffer, :user_id => user.id
      cannot :accept, GeneralOffer do |general_offer|
        (general_offer.user_id == user.id) || !general_offer.user.validated?
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
      can [:read, :create], Group
      can [:update], Group do |g|
        g.user_id == user.id
      end
    end
    
  end
  
end
