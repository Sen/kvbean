require 'benchmark'
require 'test_helper'

class Post
  include Kvbean::Base

  kv_field :num
end


Benchmark.bm do |x|
  redis = ::Redis.new
  redis.del('post:*')
  redis.keys("post:*").each do |key|
    redis.del key
  end
  Post.destroy_all
  [1000, 10000].each do |n|
    nums = 1.upto(n).map { |i| rand(1..i * 1000).to_s }
    x.report("create(#{n}):\n") do
      nums.each do |i|
        Post.create(num: i)
      end
    end
    x.report("get all(#{n}):\n") do
      Post.all
    end
    x.report("destroy all(#{n}):\n") do
      redis.del('post:*')
      redis.keys("post:*").each do |key|
        redis.del key
      end
      Post.destroy_all
    end
  end
end
