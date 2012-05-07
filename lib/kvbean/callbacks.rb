module Kvbean
  module Callbacks
    module InstanceMethods
      %w( create save update destroy ).each do |method|
        class_eval(<<-EOS, __FILE__, __LINE__ + 1)
          def #{method}
            run_callbacks :#{method} do
              super
            end
          end
        EOS
      end
    end

    def self.included(base)
      base.send :extend,  ActiveModel::Callbacks
      base.instance_eval do
        define_model_callbacks :create, :save, :update, :destroy
      end
      base.send :include, InstanceMethods
    end
  end
end
