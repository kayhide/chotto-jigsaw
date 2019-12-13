module FireRecord
  module Scope
    extend ActiveSupport::Concern

    def save!
      doc = id.present? ? scope.doc(id) : scope.doc
      doc.set attributes.except(self.class.primary_key)
      self.id = doc.document_id
      self.class.has_timestamp ? reload : self
    end

    def update! attrs
      self.attributes = attrs
      save!
    end

    def reload
      decode scope.doc(id).get
    end

    def scope
      self.class.scope
    end

    module ClassMethods
      def scope
        ::FireRecord.client.col(model_name.plural)
      end

      def build attrs = {}
        new(attrs)
      end

      def create! attrs = {}
        build(attrs).save!
      end

      def find id
        build.decode scope.doc(id).get
      end

      def all
        scope.get.map do |doc|
          new.decode(doc)
        end
      end

      def delete_all
        scope.get do |doc|
          ::FireRecord.client.doc(doc.document_path).delete
        end
      end
    end
  end
end
