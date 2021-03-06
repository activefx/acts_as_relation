module ActiveRecord

  module ActsAsModules; end

  module ActsAsRelation
    extend ActiveSupport::Concern

    module ClassMethods

      def acts_as(model_name, scope=nil, options={})
        if scope.is_a?(Hash)
          options = scope
          scope   = nil
        end

        name             = model_name.to_s.underscore.singularize
        class_name       = options[:class_name] || name.camelcase
        association_name = options[:as] || acts_as_association_name(name)
        foreign_key      = options[:foreign_key] || "#{association_name}_id"
        module_name      = "ActsAs#{name.camelcase}"
        klass            = class_name.constantize

        unless ActiveRecord::ActsAsModules.const_defined? module_name
          # Create ActsAsModel module
          acts_as_model = Module.new
          ActiveRecord::ActsAsModules.const_set(module_name, acts_as_model)

          has_one_or_many_options = {
            :class_name  => class_name,
            :foreign_key => foreign_key,
            :autosave    => true,
            :validate    => options.fetch(:validate, false),
          }

          acts_as_model.module_eval do
            singleton = class << self ; self end
            singleton.send :define_method, :included do |base|
              superclass_of = klass.acts_as_superclass_of
              if superclass_of
                has_one_or_many_options[:dependent] = options[:dependent]	if options[:dependent]
                base.belongs_to association_name.to_sym, scope, has_one_or_many_options
              else
                has_one_or_many_options[:as] = association_name
                has_one_or_many_options[:dependent] = options.fetch(:dependent, :destroy)
                base.has_one association_name.to_sym, scope, has_one_or_many_options
              end
              base.validate "#{association_name}_must_be_valid".to_sym
              base.alias_method_chain association_name.to_sym, :autobuild

              if defined?(::ProtectedAttributes)
                base.attr_accessible.update(klass.attr_accessible)
              end
            end

            define_method "#{association_name}_with_autobuild" do
              send("#{association_name}_without_autobuild") || send("build_#{association_name}")
            end

            define_method :method_missing do |method, *arg, &block|
              if (method.to_s == 'id' || method.to_s == association_name) || !send(association_name).respond_to?(method)
                super(method, *arg, &block)
              else
                send(association_name).send(method, *arg, &block)
              end
            end

            define_method :respond_to? do |method, include_private_methods = false|
              super(method, include_private_methods) || send(association_name).respond_to?(method, include_private_methods)
            end

            define_method :parent_association_foreign_keys do
              ( class_name.to_s.constantize.reflect_on_all_associations.map(&:name) -
                [ association_name.to_sym ]
              ).map{ |a| a.to_s + '_id' }
            end

            define_method :[] do |key|
              if send(:parent_association_foreign_keys).include? key.to_s
                send(association_name)[key]
              else
                super(key)
              end
            end

            define_method :[]= do |key, value|
              if send(:parent_association_foreign_keys).include? key.to_s
                send(association_name)[key] = value
              else
                super(key, value)
              end
            end

            define_method :is_a? do |klass|
              klass == class_name.constantize ? true : super(klass)
            end
            alias_method :instance_of?, :is_a?
            alias_method :kind_of?, :is_a?

            private

            define_method "#{association_name}_must_be_valid" do
              unless send(association_name).valid?
                send(association_name).errors.each do |att, message|
                  att = att.to_s.split('.').last
                  errors.add(att, message)
                  errors.add("#{association_name}_attributes_#{att}", message)
                end
              end
            end
          end
        end

        class_eval do
          include "ActiveRecord::ActsAsModules::#{module_name}".constantize
        end

        if options.fetch :auto_join, true
          class_eval "default_scope -> { joins(:#{association_name}) }"
        end

        code = <<-EndCode
          def acts_as_model_name
            :#{name}
          end
        EndCode
        instance_eval code, __FILE__, __LINE__
      end
      alias :is_a :acts_as

      attr_reader :acts_as_superclass_of

      def acts_as_superclass options={}
        if @acts_as_superclass_of = options[:of]
          # inverse mode: each of the subclasses has_one superclass

          case @acts_as_superclass_of
          when Array
            @acts_as_superclass_of = Hash[*@acts_as_superclass_of.collect {|v| [v,{}]}.flatten]
          when !Hash
            @acts_as_superclass_of = {@acts_as_superclass_of => {}}
          end

          @acts_as_superclass_of.each do |assoc_name, options|
            assoc_options = options.dup
            assoc_options[:autosave] = true
            assoc_options[:dependent]   ||= :restrict_with_exception
            assoc_options[:class_name]  ||= assoc_name.to_s.singularize.camelize
            options[:as] = (assoc_options.delete(:as) || :"as_#{assoc_name}")
            assoc_options[:foreign_key] ||= "#{acts_as_association_name(self.name.singularize.underscore)}_id"
            type = (assoc_options.delete(:type) || :many)
            unless [:one,:many].include?(type)
              raise "invalid type '#{type.inspect}' of subclass association: must be either :one or :many"
            end

            class_eval do
              send "has_#{type}", options[:as], assoc_options
            end
          end

          class_eval do
            def specific
              self.class.acts_as_superclass_of.collect do |assoc_name,options|
                if options[:type] == :one
                  [send(options[:as])]
                else
                  send(options[:as]).to_a
                end
              end.flatten.compact
            end
          end
        else
          # normal mode: the superclass has_one specific association
          association_name = options[:as] || acts_as_association_name

          code = <<-EndCode
            belongs_to :#{association_name}, :polymorphic => true

            def specific
              self.#{association_name}
            end
            alias :specific_class :specific
          EndCode
          class_eval code, __FILE__, __LINE__
        end
      end
      alias :is_a_superclass :acts_as_superclass

      def acts_as_association_name model_name=nil
        model_name ||= self.name
        "as_#{model_name.to_s.demodulize.singularize.underscore}"
      end

      def acts_as_other_model?
        respond_to? :acts_as_model_name
      end

    end # end Class Methods

  end # end ActsAsRelation
end # end ActiveRecord

class ActiveRecord::Base
  include ActiveRecord::ActsAsRelation
end
