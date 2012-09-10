class Ability
  include CanCan::Ability

  def initialize(identity)
    identity ||= Identity.new # guest user (not logged in)

    # Logged in users:
    unless identity.new_record?
      # The owner of the pool can read/edit/update it
      can [:read, :edit, :update], Pool, :owner_id => identity.id

      #The owner of the pool that these objects are in can read/edit/update the objects
      can [:read, :edit, :update], [Node, Model, Exhibit, MappingTemplate], :pool=>{ :owner_id => identity.id}
      can :create, [Exhibit, Model, Node,  Pool, MappingTemplate]
    end
  end
end
