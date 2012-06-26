# Don't delete comments! They are used in gems for adding abilities
class Ability
  
  include CanCan::Ability
  
  def initialize(user)
    
    # open ability
    can :create, Need
    
    if user.try(:admin?)
      can :manage, :all      
      # admin ability
    elsif user
      # user ability
      can :manage, User, :id => user.id     
      can [:create, :read], Need 
      can :update, Need, :user_id => user.id
      can [:create, :index], Offer
      can :accept, Offer do |offer|
        offer.need.user_id == user.id
      end
    end
    
  end
  
end
