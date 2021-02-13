require 'rails/version'
require 'rails' if Rails::VERSION::MAJOR > 2

module FormtasticTasks
  #write all found models/columns to a file where GetTexts ruby parser can find them
  def store_model_attributes(options)
    file = options[:to] || 'locale/model_attributes.rb'
    begin
      File.open(file,'w') do |f|
        f.puts "#DO NOT MODIFY! AUTOMATICALLY GENERATED FILE!"
        ModelAttributesFinder.new.find(options).each do |model,column_names|
          f.puts("_('#{model.to_s}')")
          f.puts("_('#{model.to_s.pluralize}')")

          #all columns namespaced under the model
          column_names.each do |attribute|
            translation = model.formtastic_translation_for_attribute_name(attribute)
            f.puts("_('#{translation}')")
            f.puts("_('#{translation}|hint')")
          end
        end
        f.puts "#DO NOT MODIFY! AUTOMATICALLY GENERATED FILE!"
      end
    rescue
      puts "[Error] Attribute extraction failed. Removing incomplete file (#{file})"
      File.delete(file)
      raise
    end
  end
  
	
 
  module_function :store_model_attributes

  class ModelAttributesFinder
    # options:
    #   :ignore_tables => ['cars',/_settings$/,...]
    #   :ignore_columns => ['id',/_id$/,...]
    # current connection ---> {'cars'=>['model_name','type'],...}
    def find(options)
      found = ActiveSupport::OrderedHash.new([])
      models.each do |model|
        if ignored?(model.name, options[:ignore_models])
          puts "#{model.name} IGNORED"
          next
        end
        puts "#{model.name}"
        attributes = model_attributes(model, options[:ignore_tables], options[:ignore_columns])
        stored_attributes = stored_attributes(model, options[:ignore_tables], options[:ignore_columns])
        #puts "#{model} -> #{attributes.inspect}"
        if attributes.any? or stored_attributes.any?
          found[model] = (attributes + stored_attributes).sort
        end
      end
      found
    end

    def initialize
      connection = ::ActiveRecord::Base.connection
      @existing_tables = (Rails::VERSION::MAJOR >= 5 ? connection.data_sources : connection.tables)
    end

    # Rails < 3.0 doesn't have DescendantsTracker.
    # Instead of iterating over ObjectSpace (slow) the decision was made NOT to support
    # class hierarchies with abstract base classes in Rails 2.x
    def model_attributes(model, ignored_tables, ignored_cols)
      return [] if model.abstract_class? && Rails::VERSION::MAJOR < 3

      if !ignored?(model.table_name, ignored_tables) && @existing_tables.include?(model.table_name)
        model.columns.reject { |c| ignored?(c.name, ignored_cols) }.collect { |c| c.name }
      else
        []
      end
    end

    def stored_attributes(model, ignored_tables, ignored_cols)
      return [] if model.abstract_class? && Rails::VERSION::MAJOR < 3

      if !ignored?(model.table_name, ignored_tables) && @existing_tables.include?(model.table_name)
        stored_attrs = []
        model.stored_attributes.each do |k,v|
          stored_attrs << v.reject { |c| ignored?(c.to_s, ignored_cols) }.collect { |x| x.to_s}
        end
        return stored_attrs.flatten.uniq
      else
        []
      end
    end

    def models
      Rails.application.eager_load! # make sure that all models are loaded so that direct_descendants works
      descendants = ::ActiveRecord::Base.descendants

      # In rails 5+ user models are supposed to inherit from ApplicationRecord
      if defined?(::ApplicationRecord)
        descendants += ApplicationRecord.direct_descendants
        descendants.delete ApplicationRecord
      end

      descendants
    end

    def ignored?(name,patterns)
      return false unless patterns
      patterns.detect{ |p| p.to_s == name.to_s or (p.is_a?(Regexp) and name=~p) }
    end
  end
end

module ActiveModel
  module Translation
    def formtastic_translation_for_attribute_name(attribute)
      attribute_name = attribute.to_s
      if attribute_name.ends_with?('_id')
        return "#{self.name}|#{humanize_class_name(attribute_name)}" # strips the _id part
      elsif attribute_name.ends_with?('_i18n')
        return "#{self.name}|#{humanize_class_name(attribute_name.chomp('_i18n'))}" # strips the _i18n part
      else
        return "#{self.name}|#{attribute_name.split('.').map! {|a| a.humanize }.join('|')}"
      end
    end

    def humanize_class_name(name=nil)
      name ||= self.to_s
      name.underscore.humanize
    end
  end
end