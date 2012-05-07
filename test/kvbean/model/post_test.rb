require 'test_helper'

class PostTest < ActiveSupport::TestCase

  setup do
    @redis = ::Redis.new
  end

  teardown do
    @redis.del('post:*')
    @redis.keys("post:*").each do |key|
      @redis.del key
    end
    Post.destroy_all
  end

  test "callbacks" do
    post = Post.create(title: 'i am a title')
    assert_equal post.content, 'i am a content'
  end

  test "observer" do
    post = Post.create(title: 'i am a title')
    assert_equal post.another_content, 'i am another content'
  end

end
