require 'test_helper'

class Kvmodel
  include Kvbean::Base

  kv_field :content

  def id
    1
  end
end

class KvmodelTest < ActiveSupport::TestCase

  setup do
    Kvmodel.redis.del('kvmodel:content:123')
    Kvmodel.redis.del('kvmodel:content:456')
  end

  test "redis" do
    assert_equal Kvmodel.redis.class.name, 'Redis'
    assert_equal Kvmodel.new.send(:redis).class.name, 'Redis'
  end

  test "namespace" do
    assert_equal Kvmodel.namespace, 'kvmodel'
  end

  test "set namespace" do
    Kvmodel.namespace = 'test_kvmodel'
    assert_equal Kvmodel.namespace, 'test_kvmodel'
  end

  test "redis_key" do
    assert_equal Kvmodel.redis_key(['123', '456']), 'kvmodel:123:456'
  end

  test "redis set, get, del" do
    kv = Kvmodel.new
    kv.class.namespace = 'test_kvmodel'
    kv.content = '123'
    kv.send(:redis_set)
    key = kv.send(:redis_key)
    kv.content = '456'
    assert_equal kv.content, '456'
    data = kv.send(:redis_get)
    assert_equal kv.content, '123'
    kv.send(:redis).del(key)
  end

  test "raw create" do
    kv = Kvmodel.new
    kv.content = '123'
    kv.send :raw_create
    assert_equal ActiveSupport::JSON.decode(Kvmodel.redis.get('kvmodel:1')), { "content"=>"123", "created_at"=>nil, "updated_at"=>nil }
    assert_equal Kvmodel.redis.smembers('kvmodel:content:123'), ['1']
    Kvmodel.redis.del('kvmodel:1')
    Kvmodel.redis.del('kvmodel:content:123')
    Kvmodel.redis.del('kvmodel:created_at:')
    Kvmodel.redis.del('kvmodel:updated_at:')

    assert_equal Kvmodel.redis.keys('kvmodel:*'), []
  end

  test "raw update" do
    kv = Kvmodel.new
    kv.content = '123'
    kv.send :raw_create
    kv.content = '456'
    kv.send :raw_update

    assert_equal ActiveSupport::JSON.decode(Kvmodel.redis.get('kvmodel:1')), { "content" => "456", "created_at"=>nil, "updated_at"=>nil }
    assert_equal Kvmodel.redis.smembers('kvmodel:content:456'), ['1']
    Kvmodel.redis.del('kvmodel:1')
    Kvmodel.redis.del('kvmodel:content:456')
    Kvmodel.redis.del('kvmodel:created_at:')
    Kvmodel.redis.del('kvmodel:updated_at:')

    assert_equal Kvmodel.redis.keys('kvmodel:*'), []
  end

  test "raw destroy" do
    kv = Kvmodel.new
    kv.content = '123'
    kv.send :raw_create
    kv.send :raw_destroy

    assert_equal Kvmodel.redis.keys('kvmodel:*'), []
  end
end
