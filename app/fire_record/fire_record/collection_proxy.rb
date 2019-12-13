module FireRecord
  class CollectionProxy

    module OverloadedMethods
      def model_name
        @klass.model_name
      end

      def scope
        @owner.scope.doc(@owner.id).col(model_name.plural)
      end

      def build attrs = {}
        this_scope = scope
        @klass.new({ @reflection.name => @owner }.merge(attrs)).tap do |obj|
          obj.define_singleton_method :scope do
            this_scope
          end
        end
      end
      alias_method :new, :build
    end

    def initialize klass, reflection, owner
      extend ::FireRecord::Scope::ClassMethods
      extend OverloadedMethods

      @klass = klass
      @reflection = reflection
      @owner = owner
    end
  end
end
