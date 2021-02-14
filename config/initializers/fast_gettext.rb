if Rails.env.development?
	require "missing_translation_logger"
	repos = [
		FastGettext::TranslationRepository.build('app', path: 'locale', type: :po), #, ignore_fuzzy: false, report_warning: true),
		FastGettext::TranslationRepository.build('logger', type: :logger, callback: MissingTranslationLogger.new)
	]
	FastGettext.add_text_domain 'app', type: :chain, chain: repos
else
	repos = [
		FastGettext::TranslationRepository.build('app', path: 'locale', type: :po) #, ignore_fuzzy: false, report_warning: false),
	]
	FastGettext.add_text_domain 'app', type: :chain, chain: repos
end
FastGettext.default_text_domain = 'app'
FastGettext.default_available_locales = [ 'en', 'fi' ] # Rails.application.config.i18n.available_locales
FastGettext.default_locale = 'en' # Rails.application.config.i18n.default_locale

#I18n.enforce_available_locales = false
#I18n.default_locale = Rails.application.config.i18n.default_locale

module ActiveRecord
	class Errors
		# allow a proc as a user defined message
		 def add(attribute, message = nil, options = {})
			 message = options[:default].call if options[:default].is_a?(Proc)
			 message ||= :invalid
			 message = generate_message(attribute, message, options) if message.is_a?(Symbol)
			 @errors[attribute.to_s] ||= []
			 @errors[attribute.to_s] << message
		 end
	end
end
