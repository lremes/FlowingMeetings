class GettextLocalizer
	class Cache
		def get(key)
			cache[key]
		end

		def has_key?(key)
			cache.has_key?(key)
		end

		def set(key, result)
			cache[key] = result
		end

		def cache
			@cache ||= {}
		end

		def clear!
			cache.clear
		end
	end

	attr_accessor :builder

	def self.cache
		@cache ||= Cache.new
	end

	def initialize(current_builder)
		self.builder = current_builder
	end

	def localize(key, value, type, options = {}) # @private
		key = value if value.is_a?(::Symbol)

		if value.is_a?(::String)
			escape_html_entities(value)
		else
			use_i18n = value.nil? ? i18n_lookups_by_default : (value != false)
			use_cache = i18n_cache_lookups
			cache = self.class.cache

			if use_i18n
				model_name, nested_model_name = normalize_model_name(builder.model_name.underscore)

				action_name = builder.template.params[:action].to_s rescue ''
				attribute_name = key.to_s
				
				i18n_key = [model_name.camelize, key.to_s.humanize]
				if type != :label
					i18n_key << type
				end
				
				gettext_key = i18n_key.join('|')

				puts "[i18n] Generated gettext key '#{gettext_key}' for #{key}, #{value}, #{type}, #{options.inspect}"
				# look in the cache first
				if use_cache
					cache_key = [::I18n.locale, action_name, model_name, nested_model_name, attribute_name, key, value, type, options]
					return cache.get(cache_key) if cache.has_key?(cache_key)
				end

				unless options.blank?
					i18n_value = _(gettext_key)
				else
					i18n_value = _(gettext_key) % options
				end

				# save the result to the cache
				result = (i18n_value.is_a?(::String) && i18n_value.present?) ? escape_html_entities(i18n_value) : nil
				cache.set(cache_key, result) if use_cache
				result
			end
		end
	end

	protected

	def normalize_model_name(name)
		if name =~ /(.+)\[(.+)\]/
			# Nested builder case with :post rather than @post
			# TODO: check if this is no longer required with a minimum of Rails 4.1
			[$1, $2]
		elsif builder.respond_to?(:options) && builder.options.key?(:as)
			[builder.options[:as].to_s]
		elsif builder.respond_to?(:options) && builder.options.key?(:parent_builder)
			# Rails 3.0+ nested builder work-around case, where :parent_builder is provided by f.semantic_form_for
			[builder.options[:parent_builder].object_name.to_s, name]
		else
			# Non-nested case
			[name]
		end
	end

	def escape_html_entities(string) # @private
		if (builder.escape_html_entities_in_hints_and_labels) ||
			 (self.respond_to?(:escape_html_entities_in_hints_and_labels) && escape_html_entities_in_hints_and_labels)
			string = builder.template.escape_once(string) unless string.respond_to?(:html_safe?) && string.html_safe? == true # Accept html_safe flag as indicator to skip escaping
		end
		string
	end

	def i18n_lookups_by_default
		builder.i18n_lookups_by_default
	end

	def i18n_cache_lookups
		builder.i18n_cache_lookups
	end

end