class PostObserver < ActiveRecord::Observer
  observe :post

  def before_create(record)
    record.another_content = 'i am another content'
  end

end
