module FireRecord
  class Configurations

    def self.configurations
      @cofigurations ||= build_configs("firestore.yml")
    end

    def configs_for env_name: env_name
      self.class.configurations[env_name]
    end

    private

    def self.build_configs filename
      file = Rails.root.join("config", filename)
      YAML.load(open(file))
    end
  end
end
