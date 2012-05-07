module Kvbean
  module Validations

    module InstanceMethods
      %w( create save update ).each do |method|
        class_eval(<<-EOS, __FILE__, __LINE__ + 1)
          def #{method}
            super if run_validations!
          end
        EOS
      end
    end

    def self.included(base)
      base.send :include, ActiveModel::Validations
      base.send :include, InstanceMethods
    end
  end
end
