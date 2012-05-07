require 'test_helper'

class MessageTest < ActiveSupport::TestCase

  setup do
    @redis = ::Redis.new
    now = Time.now
    current = Time.current
    Time.stubs(:now).returns(now)
    Time.stubs(:current).returns(current)
    @db_time = (current || now)
  end

  teardown do
    @redis.del('message:*')
    @redis.keys("message:*").each do |key|
      @redis.del key
    end
    Message.destroy_all
  end

  test "kv_field" do
    assert_equal Message.kv_fields.sort, [:content, :title, :user_id, :created_at, :updated_at].sort
  end

  test "changes" do
    m = Message.new
    m.content = 'new_content'
    assert_equal m.content, 'new_content'
    assert m.changed?
    assert_equal m.changes, { "content" => [nil, 'new_content'] }
    m.send :saved

    m.content = 'another_new_content'
    assert m.changed?
    assert_equal m.changes, { "content" => ['new_content', 'another_new_content'] }
  end

  test "save" do
    m = Message.new
    m.content = 'new_content'
    m.save
    assert_not_blank m.id
    decoded = ActiveSupport::JSON.decode(@redis.get("message:#{m.id}")).delete_if{|k,v| ['updated_at', 'created_at'].include?(k) }
    assert_equal decoded, { "content" => "new_content", "id" => m.id, "title" => nil, "user_id" => nil }
    assert_equal @redis.smembers('message:content:new_content'), [m.id]
  end

  test 'update' do
    m = Message.new
    m.content = 'new_content'
    m.save

    m.content = 'another_new_content'
    m.save

    assert_not_blank m.id
    decoded = ActiveSupport::JSON.decode(@redis.get("message:#{m.id}")).delete_if{|k,v| ['updated_at', 'created_at'].include?(k) }
    assert_equal decoded, { "content" => "another_new_content", "id" => m.id, "title" => nil, "user_id" => nil }
    assert_equal @redis.smembers('message:content:another_new_content'), [m.id]
  end

  test 'destroy' do
    m = Message.new
    m.content = 'new_content'
    m.save
    m.destroy

    assert_blank @redis.get("message:#{m.id}")
    assert_blank @redis.smembers('message:content:another_new_content')
  end

  test "find" do
    m = Message.new
    m.content = 'new_content'
    m.save
    assert Message.find(m.id) == m
  end

  test "create" do
    m = Message.create(content: 'create content')
    assert_not_blank m.id
    assert_equal Message.first.content, 'create content'
  end

  test "create!" do
    Message.stubs(:create).returns(nil)
    assert_raise Kvbean::InvalidRecord do
      Message.create!(content: 'create content')
    end
  end

  test "all" do
    m1 = Message.create(content: 'new_content')
    m2 = Message.create(content: 'another_new_content')
    assert_equal Message.all.size, 2
  end

  test "first" do
    m1 = Message.new
    m1.content = 'new_content'
    m1.save
    m2 = Message.new
    m2.content = 'another_content'
    m2.save
    assert Message.first == m1
  end

  test "last" do
    m1 = Message.new
    m1.content = 'new_content'
    m1.save
    m2 = Message.new
    m2.content = 'another_content'
    m2.save
    assert Message.last == m2
  end

  test "count" do
    1.upto(10) do
      m = Message.new
      m.content = '123'
      m.save
    end
    assert_equal Message.count, 10
  end

  test "class.update" do
    m1 = Message.create(content: 'content')
    Message.update(m1.id, content: 'new_content')
    assert_equal Message.all.first.content, 'new_content'
  end

  test "timestamp" do
    m = Message.create(content: 'content')
    assert_equal m.created_at, @db_time
    assert_equal m.updated_at, @db_time
  end

  test "find_by_?" do
    1.upto(10).each do |i|
      Message.create(content: 'content', user_id: i)
    end

    Message.create(content: 'content', user_id: 1)

    assert_equal Message.find_by_user_id(1), Message.first
  end

end
