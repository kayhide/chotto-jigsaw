require "google/cloud/firestore"

module FireRecord
  module Client
    attr_reader :config

    def self.connect
      path = Rails.root.join("config/firestore.yml")
      @config = Rails.application.config_for(path).with_indifferent_access
      if @config.key?(:emulator_port)
        @config[:emulator_host] = [@config[:emulator_host], @config.delete(:emulator_port)].join(':')
      elsif ENV.key?("GOOGLE_APPLICATION_CREDENTIALS")
        creds = ENV["GOOGLE_APPLICATION_CREDENTIALS"]
        if !File.exist?(creds)
          begin
            JSON.parse(creds)
            path = File.expand_path("~/.google_application_credentials.json")
            open(path, "w") do |io|
              io << creds
            end
            ENV["GOOGLE_APPLICATION_CREDENTIALS"] = path
          rescue
          end
        end
      end
      Google::Cloud::Firestore.new(**@config.symbolize_keys)
    end
  end
end
