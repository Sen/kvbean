Kvbean
======

Make redis on rails life easier

Install
-------

put this code in Gemfile

```ruby
gem 'kvbean'
```


Usage
-----

```ruby
class Message
  include Kvbean::Base

  kv_field :content, :title
end

Message.create(title: 'i am title', content: 'i am content')

Message.find_by_title('i am title')
Message.find_all_by_title('i am title')

message = Message.find_or_create_by_title('i am title')

message.id # => 7b4cfa9a1426b5fad5c8cd17aa
message.exists? # => true, alias: persisted?,
message.new_record? # => false
message.created_at # => Tue, 08 May 2012 09:54:20 UTC +00:00
message.updated_at # => Tue, 08 May 2012 09:54:20 UTC +00:00
message.update_attributes(title: 'new title')
message.title # => new title
Message.count # => 1

Message.first
message.last

message.destroy
Message.destroy_all

message = Message.new(title: 'i am title', content: 'i am content')
message.save
```

Callbacks
---------

```ruby
class Message
  include Kvbean::Base

  kv_field :content, :title

  before_create :set_content

  private

  def set_content
    self.content = 'some text'
  end
end
```

Validations
-----------

```ruby
class Message
  include Kvbean::Base

  kv_field :content, :title

  validates_presence_of :title
end
```

Namespace
---------

``` ruby
class Message
  include Kvbean::Base

  kv_field :content, :title
  kv_namespace :ns
end
```
Warning: the default namespace is class's name, e.g: Message class's
namespace is "message", if you have more than one app is working on redis, i think
you need to care about this.
