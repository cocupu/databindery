class Ability
  include CanCan::Ability

  def initialize(identity)
    identity ||= Identity.new # guest user (not logged in)

    # Logged in users:
    unless identity.new_record?
      alias_action :describe, :to => :read
      
      # The owner can read/edit/update it
      can [:read, :update], [Pool, Chattel], :owner_id => identity.id
      can :read, Pool, :access_controls => {:identity_id => identity.id }
      can :update, Pool, :access_controls => {:identity_id => identity.id, :access=>'EDIT' }

      #The owner of the pool that these objects are in can read/edit/update the objects
      can [:read, :update], [Node, Model, Exhibit, MappingTemplate], :pool=>{ :owner_id => identity.id}
      can :read, [Node, Model, Exhibit, MappingTemplate], :pool=>{ :access_controls=> {:identity_id => identity.id}}
      can :update, [Node, Model, Exhibit, MappingTemplate], :pool=>{ :access_controls=> {:identity_id => identity.id, :access=>'EDIT'}}

      # Allow read access to models without a pool (e.g. Model.file_entity)
      can :read, Model, :pool_id=>nil


      can :attach_file, Node, :pool=>{ :owner_id => identity.id}
      can :create, [Exhibit, Model, Node,  Pool, MappingTemplate, Chattel]

    end
    can :read, Identity  #necessary for authorizing exhibit view (through identity)
    can :read, Exhibit
  end
end
