module FireRecord
  module Document
    extend ActiveSupport::Concern
    include ActiveModel::Model
    include ActiveModel::Attributes
    include FireRecord::Reflection
    include FireRecord::Scope

    attr_reader :doc

    def becomes klass
      became = klass.allocate
      became.send(:initialize)
      @attributes.instance_variable_get("@attributes").merge!(
        became.instance_variable_get("@attributes").instance_variable_get("@attributes")
      ) { |key, old, new| old }
      became.instance_variable_set("@attributes", @attributes)
      became.instance_variable_set("@doc", @doc)
      this_scope = scope
      became.define_singleton_method :scope do
        this_scope
      end
      became
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

      def decode doc
        klass = doc.data[:type]&.constantize || self
        obj = klass.new(
          id: doc.document_id,
          **doc.data.slice(*klass.attribute_names.map(&:to_sym))
        )
        obj.instance_variable_set "@doc", doc
        obj
      end
    end
  end
end
