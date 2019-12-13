module FireRecord
  module Scope
    extend ActiveSupport::Concern

    def save!
      doc = id.present? ? scope.doc(id) : scope.doc
      self.try(:type=, self.class.name)
      doc.set attributes.except(self.class.primary_key)
      self.id = doc.document_id
      self.instance_variable_set "@doc", doc
      self
    end

    def update! attrs
      self.attributes = attrs
      save!
    end

    def reload
      obj = self.class.decode scope.doc(id).get
      self.instance_variable_set "@attributes", obj.instance_variable_get("@attributes")
      self.instance_variable_set "@doc", obj.instance_variable_get("@doc")
      self
    end

    def scope
      self.class.scope
    end

    module ClassMethods
      def scope
        klass = ancestors
                  .take_while { |m| m != FireRecord::Document }
                  .filter {|m| m.is_a? Class}
                  .last
        ::FireRecord.client.col(klass.model_name.plural)
      end

      def build attrs = {}
        new(attrs)
      end

      def create! attrs = {}
        build(attrs).save!
      end

      def find id
        decode scope.doc(id).get
      end

      def all
        scope.get.map do |doc|
          decode(doc)
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
