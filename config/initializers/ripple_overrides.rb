# for ripple devise integration
require 'orm_adapter/adapters/ripple'

Riak.disable_list_keys_warnings = true
module Ripple
  module Document

    module ClassMethods
      def belongs_to(name, args={})
        id = "#{name}_id".to_sym
        property id, String, :index=>true

        define_method "#{name}=".to_sym do |o|
          raise "Need to save #{o} before assigning it to #{self}" unless o.key
          self.instance_variable_set("@#{name}".to_sym, o)
          self.send("#{id}=".to_sym, o.key)
        end

        define_method "#{name}".to_sym do
          tmp = self.instance_variable_get("@#{name}".to_sym)
          return tmp if tmp
          klass = args[:class_name] || name.to_s
          o = klass.classify.constantize.find(self.send(id))
          self.instance_variable_set("@#{name}".to_sym, o)
          o
        end
      end
    end

  end

end
