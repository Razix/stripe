class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, Plan, id: user.plan.id
  end
end
