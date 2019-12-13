module FireRecord
  module Collection
    extend ActiveSupport::Concern

    def scope
      ::FireRecord.client.col(model_name.plural)
    end

    module ClassMethods
      def has_many_docs name
        define_method name do
          klass = name.to_s.classify.constantize
          doc_path = [klass.model_name.plural, send(klass.primary_key)].join('/')
          ::FireRecord::CollectionProxy.new(klass, name, self)
        end
      end
    end
  end
end
