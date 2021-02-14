class ErrorsController < ApplicationController
	def not_found
		respond_to do |type|
			type.html { render template: "errors/404_not_found", status: 404 }
			type.json {
				response.headers['Content-Type'] = 'application/vnd.api+json' if request.env['HTTP_ACCEPT'] == 'application/vnd.api+json'
				render json: {
					errors: [
						id: request.uuid,
						title: _('Not found'),
						source: {
							pointer: request.env["ORIGINAL_FULLPATH"] 
						}
					]
				}, status: 404
			}
			type.all  { render nothing: true, status: 404 }
		end
	end

	def internal_server_error
		respond_to do |type|
			type.html { render template: "errors/500_internal_server_error", status: 500 }
			type.json { 
				response.headers['Content-Type'] = 'application/vnd.api+json' if request.env['HTTP_ACCEPT'] == 'application/vnd.api+json'
				render json: {
					errors: [
						id: request.uuid,
						title: _('Internal server error'),
						source: {
							pointer: request.env["ORIGINAL_FULLPATH"] 
						}
					]
				}, status: 500
			}
			type.all  { render nothing: true, status: 500 }
		end
	end

	def unauthorized
		respond_to do |type|
			type.html {
				@debug_info = session[:debug]
				session.delete(:debug)
			}
			type.xml { render template: "errors/401_unauthorized", status: 401 }
			type.json { 
				response.headers['Content-Type'] = 'application/vnd.api+json' if request.env['HTTP_ACCEPT'] == 'application/vnd.api+json'
				render json: {
					errors: [
						id: request.uuid,
						title: _('Unauthorized'),
						source: {
							pointer: request.env["ORIGINAL_FULLPATH"] 
						}
					]
				}, status: 401
			}
			type.all  { render nothing: true, status: 401 }
		end
	end

	def forbidden
		respond_to do |type|
			type.html { render template: "errors/403_forbidden", status: 403 }
			type.json {
				response.headers['Content-Type'] = 'application/vnd.api+json' if request.env['HTTP_ACCEPT'] == 'application/vnd.api+json'
				render json: {
					errors: [
						id: request.uuid,
						title: _('Forbidden'),
						source: {
							pointer: request.env["ORIGINAL_FULLPATH"] 
						}
					]
				}, status: 403
			}
			type.all  { render nothing: true, status: 403 }
		end
	end
end
