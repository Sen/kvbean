module Kvbean
  module Redis
    module ClassMethods
      def redis
        @redis ||= ::Redis.new
      end

      def namespace
        @namespace ||= self.name.downcase
      end

      def namespace=(namespace)
        @namespace = namespace
      end

      def redis_key(*args)
        args.unshift(self.namespace)
        args.join(':')
      end

      def all
        from_ids(redis.sort(redis_key))
      end

      protected

      def from_ids(ids)
        ids.map { |id| existing('id' => id) }
      end

      def existing(attrs = {})
        item = self.new(attrs)
        item.new_record = false
        item.redis_get
        item
      end
    end

    module InstanceMethods
      protected

        def redis
          self.class.redis
        end

        def redis_key(*args)
          self.class.redis_key(id, *args)
        end

        def redis_set
          redis.set(redis_key, serializable_hash.to_json)
        end

        def redis_get
          data = redis.get(redis_key)
          if data
            load_to_instance(ActiveSupport::JSON.decode(data))
          else
            nil
          end
        end
        public :redis_get

        def destroy_indexes
          self.class.kv_fields.each do |field|
            old_value = changes[field].try(:first) || send(field)
            redis.srem(self.class.redis_key(field, old_value), id)
            if redis.smembers(self.class.redis_key(field, old_value)).blank?
              redis.del(self.class.redis_key(field, old_value))
            end
          end
        end

        def create_indexes
          self.class.kv_fields.each do |field|
            new_value = send(field)
            redis.sadd(self.class.redis_key(field, new_value), id)
          end
        end

        def raw_create
          redis_set
          create_indexes
          redis.sadd(self.class.redis_key, self.id)
          saved
        end

        def raw_update
          destroy_indexes
          redis_set
          create_indexes
          saved
        end

        def raw_destroy
          return if new_record?

          destroy_indexes
          redis.srem(self.class.redis_key, self.id)
          redis.del(redis_key)
        end
    end

    def self.included(base)
      base.send :extend,  ClassMethods
      base.send :include, InstanceMethods
    end
  end
end
