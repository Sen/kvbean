= Kvbean

This project rocks and uses MIT-LICENSE.

= Usage

```ruby
class Message
  include Kvbean::Base

  kv_field :content, :title
end

Message.create(title: 'i am title', content: 'i am content')

message = Message.new(title: 'i am title', content: 'i am content')
message.save
```

= callbacks

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

= validations
```ruby
class Message
  include Kvbean::Base

  kv_field :content, :title

  validates_presence_of :title
end
```
