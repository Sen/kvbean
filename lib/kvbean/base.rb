require 'SecureRandom'

module Kvbean
  module Base
    module ClassMethods
      attr_accessor :primary_key, :kv_fields

      def kv_field(*attributes)
        define_attribute_methods attributes
        @kv_fields ||= []
        attributes.each do |attribute|
          @kv_fields << attribute
          class_eval(<<-EOS, __FILE__, __LINE__ + 1)
            def #{attribute}
              @#{attribute}
            end

            def #{attribute}=(val)
              #{attribute}_will_change! unless val == @#{attribute}
              @#{attribute} = val
            end
          EOS
        end
      end

      def kv_namespace(namespace)
        @namespace = namespace.to_s
      end

      def collection(&block)
        @collection ||= Class.new(Array)
        @collection.class_eval(&block) if block_given?
        @collection
      end

      def primary_key
        @primary_key ||= 'id'
      end

      def records
        @records ||= {}
      end

      def raw_find(id)
        records[id] || raise(UnknownRecord, "Couldn't find #{self.name} with ID=#{id}")
      end

      def find(id)
        item = raw_find(id)
        item && item.dup
      end

      def first
        item = records.values[0]
        item && item.dup
      end

      def last
        item = records.values[-1]
        item && item.dup
      end

      def all
        clear_all
        super.each { |item| records[item.id] = item.dup }
        collection.new(records.values.deep_dup)
      end

      def count
        all.size
      end

      def update(id, attrs)
        find(id).update_attributes(attrs)
      end

      def destroy_all
        all.each { |item| item.destroy }
        clear_all
      end

      def clear_all
        records.clear
      end

      def create(attrs = {})
        record = self.new(attrs)
        record.save && record
      end

      def create!(attrs = {})
        create(*attrs) || raise(Kvbean::InvalidRecord)
      end

      def find_by_attribute(name, value)
        item = records.values.find {|r| r.send(name) == value }
        item && item.dup
      end

      def find_all_by_attribute(name, value)
        items = records.values.select {|r| r.send(name) == value }
        collection.new(items.deep_dup)
      end

      def method_missing(method_symbol, *args)
        method_name = method_symbol.to_s

        if method_name =~ /^find_by_(\w+)!/
          send("find_by_#{$1}", *args) || raise(UnknownRecord)
        elsif method_name =~ /^find_by_(\w+)/
          find_by_attribute($1, args.first)
        elsif method_name =~ /^find_or_create_by_(\w+)/
          send("find_by_#{$1}", *args) || create($1 => args.first)
        elsif method_name =~ /^find_all_by_(\w+)/
          find_all_by_attribute($1, args.first)
        else
          super
        end
      end
    end

    module InstanceMethods
      attr_accessor :attributes, :new_record

      def initialize(attributes = {})
        @new_record = true
        @attributes = {}.with_indifferent_access
        @attributes.merge!(self.class.kv_fields.inject({}) {|h, n| h[n] = nil; h })
        @changed_attributes = {}
        load_to_instance(attributes)
      end

      def saved
        @previously_changed = changes
        @changed_attributes.clear
        @new_record = false
      end

      def new_record?
        @new_record
      end

      def load_to_instance(attributes)
        return unless attributes
        attributes.each do |key, value|
          self.send "#{key}=".to_sym, value
        end
      end

      def reload_to_instance(attributes)
        return unless attributes
        attributes.each do |key, value|
          self.send "#{key}=".to_sym, value
        end
      end

      def update_attributes(attributes)
        load_to_instance(attributes) && save
      end

      def id
        attributes[self.class.primary_key]
      end

      def id=(value)
        attributes[self.class.primary_key] = value
      end

      def save
        new_record? ? create : update
      end

      def raw_create
        super
        self.class.records[self.id] = self.dup
      end

      def raw_update
        super
        item = self.class.raw_find(id)
        item.load_to_instance(attributes)
      end

      def raw_delete
        super
        self.class.records.delete(self.id)
      end

      def create
        self.id ||= generate_id
        @new_record = false
        raw_create
        self.id
      end

      def update
        raw_update
        true
      end

      def destroy
        raw_destroy
        true
      end

      def exists?
        !new_record?
      end
      alias_method :persisted?, :exists?

      def generate_id
        SecureRandom.hex(13)
      end

      def ==(other)
        other.equal?(self) || (other.instance_of?(self.class) && other.id == id)
      end

      def eql?(other)
        self == other
      end
    end

    def self.included(base)
      base.send :include, ActiveModel::Serialization
      base.send :include, ActiveModel::Dirty
      base.send :include, Kvbean::Redis
      base.send :extend,  ClassMethods
      base.send :include, InstanceMethods
      base.send :include, Kvbean::Validations
      base.send :include, Kvbean::Callbacks
      base.send :include, Kvbean::Observing
      base.send :include, Kvbean::Timestamp
    end

  end
end
