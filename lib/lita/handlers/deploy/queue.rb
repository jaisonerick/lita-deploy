module Lita
  module Handlers
    class Deploy < Handler
      class Queue
        def pop
          user = redis.lpop("queue")
          redis.srem("set", user) if user
          redis.set("current", user) if user
          redis.del("current") unless  user
          user
        end

        def push(name)
          fail 'You are already waiting!' if has?(name)
          unless current
            redis.set('current', name)
            return 0
          end
          pos = redis.rpush("queue", name)
          redis.sadd("set", name)
          pos
        end

        def list
          redis.smembers("set")
        end

        def has?(name)
          redis.sismember("set", name)
        end

        def remove(name)
          return unless has?(name)
          redis.lrem("queue", 0, name)
          redis.srem("set", name)
        end

        def current
          redis.get("current")
        end

        private

        def redis
          @redis ||= Redis::Namespace.new("deploy:queue",
                                          redis: Lita.redis)
        end
      end
    end
  end
end
