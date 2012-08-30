class Ability
  include CanCan::Ability

  def initialize(identity)
    identity ||= Identity.new # guest user (not logged in)

    # Logged in users:
    unless identity.new_record?
      can [:read, :edit, :update], Pool, :owner_id => identity.id
      can [:read, :edit, :update], [Node, Model, Exhibit], :pool=>{ :owner_id => identity.id}
      can :create, [Exhibit, Model, Node,  Pool]
    end
  end
end
