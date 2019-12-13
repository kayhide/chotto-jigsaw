require "google/cloud/firestore"

module FireRecord
  module Client
    attr_reader :config

    def self.connect
      path = Rails.root.join("config/firestore.yml")
      @config = Rails.application.config_for(path).with_indifferent_access
      if @config.key?(:emulator_port)
        @config[:emulator_host] = [@config[:emulator_host], @config.delete(:emulator_port)].join(':')
      end
      Google::Cloud::Firestore.new(**@config.symbolize_keys)
    end
  end
end
