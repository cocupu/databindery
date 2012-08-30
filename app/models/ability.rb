class Ability
  include CanCan::Ability

  def initialize(identity)
    identity ||= Identity.new # guest user (not logged in)

    # Logged in users:
    unless identity.new_record?
      can :read, Pool, :owner_id => identity.id
      can [:read, :edit, :update], Model, :identity_id => identity.id
      can :create, Model

      can :create, Node
      can [:read, :update], Node, :pool=>{ :owner_id => identity.id}

      can [:read, :edit, :update], Exhibit, :pool=>{ :owner_id => identity.id}
      can :create, Exhibit
    end
  end
end
