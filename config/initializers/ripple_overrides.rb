module Ripple
  module Document

    module ClassMethods
      def belongs_to(name)
        id = "#{name}_id".to_sym
        property id, String, :index=>true

        define_method "#{name}=".to_sym do |o|
          raise "Need to save #{o} before assigning it to #{self}" unless o.key
          self.send("#{id}=".to_sym, o.key)
        end

        define_method "#{name}".to_sym do
          name.to_s.classify.constantize.find(self.send(id))
        end
      end
    end

  end

end
