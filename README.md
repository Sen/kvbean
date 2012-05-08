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
# => {}

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
