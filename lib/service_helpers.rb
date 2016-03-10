module ServiceHelpers

  def self.reconnect_services!
    # Rails.cache.reconnect
    Splunk::LogSubscriptionManager.setup_splunk
  end

end
