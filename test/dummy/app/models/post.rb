class Post
  include Kvbean::Base

  before_create :set_content

  kv_field :title, :content, :another_content

  validates_presence_of :title

  private

  def set_content
    self.content = 'i am a content'
  end
end
