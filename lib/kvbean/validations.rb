module Kvbean
  module Validations

    def self.included(base)
      base.send :include, ActiveModel::Validations
    end
  end
end
