class Message
  include Kvbean::Base

  kv_field :content, :title
  kv_field :user_id
end
