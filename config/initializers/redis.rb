# frozen_string_literal: true

require "redis"
require "connection_pool"

REDIS_URL = ENV.fetch("REDIS_URL", "redis://localhost:6379/0")

$redis = ConnectionPool::Wrapper.new(size: 5, timeout: 3) do
  Redis.new(url: REDIS_URL)
end
