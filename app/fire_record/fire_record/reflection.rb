module FireRecord
  module Reflection
    extend ActiveSupport::Concern

    class BelongsTo
      include ActiveModel::Model
      include ActiveModel::Attributes
      attribute :klass
      attribute :foreign_key, :string
      attribute :name
      attribute :plural_name, :string
    end

    class HasOne
      include ActiveModel::Model
      include ActiveModel::Attributes
      attribute :klass
      attribute :foreign_key, :string
      attribute :name
      attribute :plural_name, :string
    end

    module ClassMethods
      attr_reader :reflections

      def reflections
        @reflections ||= {}
      end

      def belongs_to name
        if reflections.values.any? { |ref| ref.is_a?(BelongsTo) }
          raise "Cannot belong to more than one model"
        end
        ref = define_one_association name, BelongsTo
        define_inverse_association ref
      end

      def has_one name
        ref = define_one_association name, HasOne
        define_inverse_association ref
      end

      def define_one_association name, ref
        klass = name.to_s.classify.constantize
        foreign_key = "#{name}_#{klass.primary_key}"
        attribute foreign_key, klass.attribute_types[klass.primary_key]
        define_method name do
          val = instance_variable_get "@#{klass.primary_key}"
          val ||=
            begin
              val_ = klass.find_by({ klass.primary_key => send(foreign_key) })
              instance_variable_set "@#{klass.primary_key}", val_
              val_
            end
        end
        define_method "#{name}=" do |arg|
          instance_variable_set "@#{klass.primary_key}", arg
          send("#{foreign_key}=", arg&.send(klass.primary_key))
        end

        reflections[name.to_s] = ref.new(
          klass: klass,
          foreign_key: foreign_key,
          name: name,
          plural_name: name.to_s.pluralize
        )
      end

      def define_inverse_association ref
        this = self
        ref.klass.define_method self.model_name.plural do
          ref_obj = self
          doc_path = [ref.klass.model_name.plural, send(ref.klass.primary_key)].join('/')
          ::FireRecord::CollectionProxy.new(this, ref, self)
        end
      end
    end
  end
end
