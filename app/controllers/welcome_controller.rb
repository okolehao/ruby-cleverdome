require "savon"

class WelcomeController < ApplicationController
  def index
  	client = Savon.client(
    	wsdl: 'http://win7dev6.unitedplanners.com/CDWidgets/Services/Widgets.svc?wsdl',
    	# proxy: 'http://127.0.0.1:8888',
    	element_form_default: :unqualified,
   		#log_level: :debug
   	)

	response = client.call(
		:get_document_template,
		:attributes => { 'xmlns' => 'http://tempuri.org/' }, 
		message: {
			sessionID: 'AB1AD8C1-2480-47D7-A45E-489C52146B9E',
			docGUID: 'AB1AD8C1-2480-47D7-A45E-489C52146B9E'
		})
	render text: response.hash.inspect
  end
end
