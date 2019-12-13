module FireRecord
  module Document
    extend ActiveSupport::Concern
    include ActiveModel::Model
    include ActiveModel::Attributes

    def push!
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
      attribute :id, :integer
    end

    module ClassMethods
      def belongs_to name
        raise "Cannot belong to more than one model" if @document_belongs_to.present?

        klass = name.to_s.classify.constantize
        @document_belongs_to = klass
        attribute "#{name}_#{klass.primary_key}", klass.attribute_types[klass.primary_key]
      end

      def has_one name
        klass = name.to_s.classify.constantize
        key_name = "#{name}_#{klass.primary_key}"
        attribute key_name, klass.attribute_types[klass.primary_key]
        define_method name do
          klass.find_by({ "#{klass.primary_key}": send(key_name) })
        end
        define_method "#{name}=" do |arg|
          send("#{key_name}=", arg&.send(klass.primary_key))
        end
      end

      def col_path
        @document_belongs_to
      end

      def first
        ::FireRecord.client.col(self.model_name.plural).limit(1).get.to_a.first
      end

      def all
        ::FireRecord.client.col(self.model_name.plural).get.to_a
      end
    end
  end
end
