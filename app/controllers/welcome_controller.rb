require 'ruby-cleverdome'

class WelcomeController < ApplicationController
	def index
		client = RubyCleverdome.new(
			'http://sandbox.cleverdome.com/CDSSOService/SSOService.svc/SSO',
			'http://sandbox.cleverdome.com/CDWidgets/Services/Widgets.svc?wsdl'
			)

		path = Dir.pwd + '/cert/certificate.pem'

		session_id = client.auth('http://tempuri.org/', 4898, path, path)
		response = client.widgets_call(:get_document_template, { documentGuid: '1d50dde0-4cd9-11e3-8879-1239b5f79600', sessionID: session_id })
		
		render text: response.hash.inspect
	end
end
