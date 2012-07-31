class Ability
  include CanCan::Ability

  def initialize(identity)
    identity ||= Identity.new # guest user (not logged in)
    can :read, Model do |m|
      m.owner == identity
    end
    can :read, Node do |n|
      n.pool.owner == identity
    end
  end
end
