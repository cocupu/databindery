class Ability
  include CanCan::Ability

  def initialize(identity)
    identity ||= Identity.new # guest user (not logged in)
    can :read, Model, :owner => identity
    can :read, Node, :pool=>{ :owner_id => identity.id}
  end
end
