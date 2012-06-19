# Don't delete comments! They are used in gems for adding abilities
class Ability
  
  include CanCan::Ability
  
  def initialize(user)
    
    # open ability
    
    if user.try(:admin?)
      can :manage, :all      
      # admin ability
    elsif user
      # user ability
      can :manage, User, :id => user.id      
    end
    
  end
  
end
