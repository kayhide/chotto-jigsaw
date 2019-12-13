module FireRecord
  def self.client
    @client ||= ::FireRecord::Client.connect
  end

  class FireRecordError < StandardError; end

  class DocumentNotFound < FireRecordError; end
end
