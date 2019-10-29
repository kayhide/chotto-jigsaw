module PrefixAttribute
  extend ActiveSupport::Concern

  module ClassMethods
    def prefix_attribute prefix, attr
      alias_attribute attr, :"#{prefix}_#{attr}"
    end
  end
end
