module FireRecord
  module Scope
    extend ActiveSupport::Concern

    def save! batch = nil
      presave
      doc = id.present? ? scope.doc(id) : scope.doc
      if batch
        batch.set doc, attributes.except(self.class.primary_key)
      else
        doc.set attributes.except(self.class.primary_key)
      end
      self.id = doc.document_id
      self.instance_variable_set "@doc", doc
      self
    end

    def update! attrs, batch = nil
      self.attributes = attrs
      save! batch
    end

    def new_record?
      @doc.nil?
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

    def presave
      try(:type=, self.class.name)
      if new_record?
        try(:created_at=, ::FireRecord.client.field_server_time)
      end
      try(:update_at=, ::FireRecord.client.field_server_time)
      self
    end

    module ClassMethods
      def batch
        ::FireRecord.client.batch do |b|
          yield b
        end
      end

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

      def create! attrs = {}, batch = nil
        build(attrs).save! batch
      end

      def find id
        doc = scope.doc(id).get
        raise FireRecord::DocumentNotFound if doc.data.nil?
        decode doc
      end

      def count
        scope.get.count
      end

      def all
        scope.get.map(&method(:decode))
      end

      def delete_all
        while scope.limit(1).get.count == 1
          ::FireRecord.client.batch do |b|
            scope.limit(200).get do |doc|
              b.delete(doc.document_path)
            end
          end
        end
      end
    end
  end
end
