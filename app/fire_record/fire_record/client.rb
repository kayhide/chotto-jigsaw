require "google/cloud/firestore"

module FireRecord
  module Client
    def self.config
      path = Rails.root.join("config/firestore.yml")
      @config ||=
        Rails.application.config_for(path).with_indifferent_access.tap do |config|
          if config.key?(:emulator_port)
            config[:emulator_host] =
              [config[:emulator_host], config.delete(:emulator_port)].join(':')
          end
        end
    end

    def self.credentials
      @credentials ||=
        if ENV.key?("GOOGLE_APPLICATION_CREDENTIALS") && ENV["GOOGLE_APPLICATION_CREDENTIALS"].present?
          creds = ENV["GOOGLE_APPLICATION_CREDENTIALS"]
          if File.exist?(creds)
            open(creds, &JSON.method(:load))
          else
            JSON.parse(creds).tap do
              path = File.expand_path("~/.google_application_credentials.json")
              open(path, "w") do |io|
                io << creds
              end
              ENV["GOOGLE_APPLICATION_CREDENTIALS"] = path
            end
          end
        end
    rescue Errno::ENOENT
      raise StandardError.new("File not found of GOOGLE_APPLICATION_CREDENTIALS")
    rescue JSON::ParserError
      raise StandardError.new("Malformed json of GOOGLE_APPLICATION_CREDENTIALS")
    end

    def self.connect
      credentials
      Google::Cloud::Firestore.new(**config.symbolize_keys)
    end

    def self.create_custom_token uid, claims = {}
      if credentials.present?
        service_account_email = credentials.dig("client_email")
        private_key = OpenSSL::PKey::RSA.new(credentials.dig("private_key"))
        now_seconds = Time.now.to_i
        payload = {
          iss: service_account_email,
          sub: service_account_email,
          aud: "https://identitytoolkit.googleapis.com/google.identity.identitytoolkit.v1.IdentityToolkit",
          iat: now_seconds,
          exp: now_seconds + 3600, # Maximum expiration time is one hour
          uid: uid,
          claims: claims
        }
        JWT.encode payload, private_key, "RS256"
      end
    end
  end
end
