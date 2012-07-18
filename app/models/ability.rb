# Don't delete comments! They are used in gems for adding abilities
class Ability
  
  include CanCan::Ability
  
  def initialize(user)
    
    # open ability
    can :create, Enquiry
    can :show, Page, :draft => false
    can :create, Need
    
    if user.try(:admin?)
      can :manage, :all
      can :validate, User  
      # admin ability
    elsif user
      # user ability
      can [:create], Flag
      can [:create], Comment
      can [:read, :create], Post
      can [:update, :destroy], Post, :user_id => user.id
      can :manage, User, :id => user.id     
      cannot :index, User
      can [:create, :read, :search], Need 
      can :update, Need, :user_id => user.id
      can [:create, :index], Offer
      can [:accept, :reject], Offer do |offer|
        offer.need.user_id == user.id
      end
    end
    
  end
  
end
