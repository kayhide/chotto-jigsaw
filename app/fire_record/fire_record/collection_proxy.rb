module FireRecord
  class CollectionProxy

    module OverloadedMethods
      def model_name
        @klass.model_name
      end

      def scope
        @owner.scope.doc(@owner.id).col(@klass.model_name.plural)
      end

      def build attrs = {}
        built = @klass.new(attrs)
        built.attributes = { @owner.model_name.singular => @owner }
        this_scope = scope
        built.define_singleton_method :scope do
          this_scope
        end
        built
      end
      alias_method :new, :build
    end

    def initialize klass, name, owner
      extend ::FireRecord::Scope::ClassMethods
      extend OverloadedMethods

      @klass = klass
      @name = name
      @owner = owner
    end
  end
end
