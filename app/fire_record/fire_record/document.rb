module FireRecord
  module Document
    extend ActiveSupport::Concern
    include ActiveModel::Model
    include ActiveModel::Attributes
    include FireRecord::Reflection
    include FireRecord::Scope

    def decode doc
      self.attributes = {
        id: doc.document_id,
        **doc.data
      }
      if (self.class.has_timestamp)
        self&.created_at = doc.create_time
        self&.updated_at = doc.update_time
      end

      self
    end

    def ==(comparison_object)
      super ||
        comparison_object.instance_of?(self.class) &&
        !id.nil? &&
        comparison_object.id == id
    end

    def inspect
      inspection =
        if defined?(@attributes) && @attributes
          self.class.attribute_names.collect do |name|
            value = send(name).inspect
            "#{name}: #{value}"
          end.compact.join(", ")
        else
          "not initialized"
        end

      "#<#{self.class} #{inspection}>"
    end

    included do
      attribute primary_key, :string
    end

    module ClassMethods
      def primary_key
        "id"
      end

      def has_timestamp
        (attribute_names & %w(created_at updated_at)).present?
      end
    end
  end
end
