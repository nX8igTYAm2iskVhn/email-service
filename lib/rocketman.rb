class Rocketman
  include Singleton

  attr_reader :redis

  def deliver(email_address, queue, data, from_name=nil)
    email_headers = { 'To' => email_address }
    if from_name.present?
      email_headers['From'] = from_name
    end
    details = {
      'email_headers' => email_headers,
      'queue' => queue,
      'data' => data,
      'locale' => 'en_US',
    }
    args = [queue, details]
    job = {
      :args => args,
      :class => 'RocketmanEmailWorker'
    }
    redis.rpush('resque:queue:rocketman', job.to_json)
  end

  def connect!
    @redis = Redis.new({
      host: AppConfig.rocketman.host,
      port: AppConfig.rocketman.port,
      timeout: AppConfig.rocketman.timeout
    })
  end

  class << self
    delegate :deliver, to: :instance
  end
end

Rails.application.config.before_initialize do
  Rocketman.instance.connect!
end
