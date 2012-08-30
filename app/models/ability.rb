class Ability
  include CanCan::Ability

  def initialize(identity)
    identity ||= Identity.new # guest user (not logged in)

    # Logged in users:
    unless identity.new_record?
      can :read, Pool, :owner_id => identity.id
      can [:read, :edit, :update], [Node, Model, Exhibit], :pool=>{ :owner_id => identity.id}
      can :create, [Model, Node, Exhibit]
    end
  end
end
