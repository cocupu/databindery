class Ability
  include CanCan::Ability

  def initialize(identity)
    #identity ||= Identity.new # guest user (not logged in)
    identity ||= Identity.anonymous_visitor # guest user (not logged in)

    # Logged in users:
    unless identity.new_record? || identity == Identity.anonymous_visitor
      alias_action :describe, :to => :read
      
      # The owner can read/edit/update it
      can [:read, :update], [Pool, Chattel], :owner_id => identity.id
      can :read, Pool do |pool|
        !pool.audiences_for_identity(identity).empty?
      end
      can :update, Pool do |pool|
        pool.access_controls.where(:identity_id => identity.id, :access=>'EDIT' )
      end

      can [:read, :edit, :update, :create], AudienceCategory do |audience_category|
        can? :update, audience_category.pool
      end
      can [:read, :edit, :update, :create], Audience do |audience|
        can? :update, audience.pool
      end
      #The owner of the pool that these objects are in can read/edit/update the objects
      can [:read, :update, :destroy], [Node, Model, Exhibit, MappingTemplate], :pool=>{ :owner_id => identity.id}
      can :read, [MappingTemplate], :pool=>{ :access_controls=> {:identity_id => identity.id}}
      can [:update, :destroy], [Node, Model, Exhibit, MappingTemplate] do |target|
        can? :update, target.pool
      end

      # Allow read access to models without a pool (e.g. Model.file_entity)
      can :read, Model, :pool_id=>nil


      can :attach_file, Node, :pool=>{ :owner_id => identity.id}
      can :create, [Exhibit, Model, Node,  Pool, MappingTemplate, Chattel]

    end
    can :read, [Node, Model, Exhibit], :pool=>{ :access_controls=> {:identity_id => identity.id}}

    can :read, Identity  #necessary for authorizing exhibit view (through identity)
    can :read, Exhibit
  end
end
