module FireRecord
  def self.client
    @client ||= ::FireRecord::Client.connect
  end
end
