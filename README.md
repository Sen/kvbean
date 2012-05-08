Kvbean
======

Make redis on rails easier

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
