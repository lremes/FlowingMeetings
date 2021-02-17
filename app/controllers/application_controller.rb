class ApplicationController < ActionController::Base
	include ActionView::Helpers::JavaScriptHelper

	before_action :set_locale
	
    def locale
		(current_user.locale if current_user) || params[:locale] || session[:locale] || I18n.default_locale
	end

    def handle_exception(r, e, msg, obj = nil)
		logger.error(e.backtrace.join("\n"))
        logger.error(e)

		resp = {
			id: r.uuid,
			status: :error,
			message: escape_javascript( msg ),
			error_details: {
				description: escape_javascript( _(e.message) )
			}
		}

		extra_data = { msg: msg }
		if obj.present? 
			#logger.error(obj)
			if obj.respond_to?(:errors)
				logger.error(obj.errors)
				resp[:error_details][:model] = obj.errors.full_messages
				extra_data[:errors] = obj.errors.full_messages
			else
				resp[:error_details][:model] = obj
				extra_data[:object] = obj
			end
		else
			if e.respond_to?(:record)
				extra_data[:record] = e.record
				if e.record.respond_to?(:errors)
					logger.error(e.record.errors.inspect)
					extra_data[:errors] = e.record.errors.full_messages
					resp[:error_details][:model] = e.record.errors.full_messages
				end
			end
		end

		ExceptionNotifier.notify_exception(e, env: request.env, data: extra_data)
		logger.error(resp.to_json)

		if r.format.symbol == :json
			return resp.to_json
		end
		resp
	end

	protected
	
	def not_found
		raise ActionController::RoutingError.new('Not Found')
	end

	def unauthorized
		raise ActionController::RoutingError.new('Unauthorized')
	end

	private

	def locale
		params[:locale] || session[:locale] || I18n.default_locale
	end

	def set_locale
		if params[:locale]
			session[:locale] = params[:locale]
		end

		I18n.locale = FastGettext.set_locale(locale())
		logger.debug("Locale set to '#{I18n.locale}'")
	end
end
