require "savon"

class WelcomeController < ApplicationController
  def widgets_call(client, method, locals)
  	response = client.call(
		method,
		:attributes => { 'xmlns' => 'http://tempuri.org/' }, 
		message: { sessionID: 'EE282ABB-7BC3-42D3-BE98-9F8CE4217A12' } .merge(locals) )
  end

  def index
  	client = Savon.client(
    	wsdl: 'http://sandbox.cleverdome.com/CDWidgets/Services/Widgets.svc?wsdl',
    	# proxy: 'http://127.0.0.1:8888',
    	element_form_default: :unqualified,
   		# log_level: :debug
   	)

	response = widgets_call(client, :get_document_template, { documentGuid: '1d50dde0-4cd9-11e3-8879-1239b5f79600' })
	render text: response.hash.inspect
  end
end
