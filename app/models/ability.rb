class Ability
  include CanCan::Ability

  def initialize(identity)
    identity ||= Identity.new # guest user (not logged in)
    can :read, Model, :identity_id => identity.id
    can :read, Node, :pool=>{ :owner_id => identity.id}
    can [:read, :edit, :update], Exhibit, :pool=>{ :owner_id => identity.id}
    can :create, Exhibit unless identity.new_record?
  end
end