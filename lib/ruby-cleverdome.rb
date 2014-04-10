require 'nokogiri'
require 'savon'
require 'uuid'
require 'signed_xml'

class RubyCleverdome
		def self.initialize()
			#hard coded endpoints could be passed
			sso_endpoint = 'http://sandbox.cleverdome.com/CDSSOService/SSOService.svc/SSO'
			widgets_wsdl = 'http://sandbox.cleverdome.com/CDWidgets/Services/Widgets.svc?wsdl'
			@sso_client = Savon.client(
	  			endpoint: sso_endpoint,
	  			namespace: 'urn:up-us:sso-service:service:v1',
				# proxy: 'http://127.0.0.1:8888',
				# log_level: :debug
	  			)
			@widgets_client = Savon.client(
				wsdl: widgets_wsdl,
				# proxy: 'http://127.0.0.1:8888',
				element_form_default: :unqualified,
				# log_level: :debug
			)
		end

	  	def self.auth()
			#hard coded creds could be passed
			provider = 'http://tempuri.org/'
			uid = 4898
			private_key_file = Dir.pwd + '/cert/certificate.pem'
			certificate_file = Dir.pwd + '/cert/certificate.pem'


	  		req = self.create_request(provider, uid)

			req = self.sign_request(req, private_key_file, certificate_file)

			resp = self.saml_call(req)
			resp_doc = Nokogiri::XML::Document.parse(resp)
	  		resp_doc.remove_namespaces!
			self.check_resp(resp_doc)

			session_id = resp_doc.xpath('//Assertion//AttributeStatement//Attribute[@Name="SessionID"]//AttributeValue')[0].content

			response = self.widgets_call(:get_document_template, { documentGuid: '1d50dde0-4cd9-11e3-8879-1239b5f79600', sessionID: session_id })

			response
	  	end

		def self.widgets_call(method, locals)
	  		response = @widgets_client.call(
				method,
				:attributes => { 'xmlns' => 'http://tempuri.org/' }, 
				message: { sessionID: 'EE282ABB-7BC3-42D3-BE98-9F8CE4217A12' } .merge(locals) )
	  	end

		def self.create_request(provider, uid)
			builder = Nokogiri::XML::Builder.new do |xml|
				xml['s'].Envelope('xmlns:s' => 'http://schemas.xmlsoap.org/soap/envelope/') {
					xml['s'].Header {
						xml.ActivityId(
							UUID.new.generate, 
							'CorrelationId' => UUID.new.generate,
							:xmlns 			=> 'http://schemas.microsoft.com/2004/09/ServiceModel/Diagnostics')
					}
					xml['s'].Body(
						'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
						'xmlns:xsd' => 'http://www.w3.org/2001/XMLSchema') {
						xml.AuthnRequest(
							'ID' 				=> '_' + UUID.new.generate,
							'Version' 			=> '2.0',
							'IssueInstant' 		=> Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ"),
							'IsPassive'			=> false,
							'ProtocolBinding' 	=> 'urn:oasis:names:tc:SAML:2.0:bindings:SOAP',
							'ProviderName'		=> provider,
							:xmlns 				=> 'urn:oasis:names:tc:SAML:2.0:protocol') {
							xml.Issuer(
								@provider,
								'Format'	=> 'urn:oasis:names:tc:SAML:2.0:nameidformat:transient',
								:xmlns 		=> 'urn:oasis:names:tc:SAML:2.0:assertion')
							xml.Signature(:xmlns => 'http://www.w3.org/2000/09/xmldsig#') {
								xml.SignedInfo {
									xml.CanonicalizationMethod( 'Algorithm' => 'http://www.w3.org/TR/2001/REC-xml-c14n-20010315' ) { xml.text '' }
									xml.SignatureMethod( 'Algorithm' => 'http://www.w3.org/2000/09/xmldsig#rsa-sha1' ) { xml.text '' }
									xml.Reference( 'URI' => '' ) {
										xml.Transforms {
											xml.Transform( 'Algorithm' => 'http://www.w3.org/2000/09/xmldsig#enveloped-signature' ) { xml.text '' }
											xml.Transform( 'Algorithm' => 'http://www.w3.org/TR/2001/REC-xml-c14n-20010315' ) { xml.text '' }
										}
										xml.DigestMethod( 'Algorithm' => 'http://www.w3.org/2000/09/xmldsig#sha1' ) { xml.text '' }
										xml.DigestValue
									}
								}
								xml.SignatureValue
								xml.KeyInfo {
									xml.X509Data {
										xml.X509Certificate
									}
								}
							}
							xml.Subject( :xmlns => 'urn:oasis:names:tc:SAML:2.0:assertion' ) {
								xml.NameID(
									uid,
									'Format'=>'urn:oasis:names:tc:SAML:2.0:nameid-format:transient')
							}
							xml.NameIDPolicy( 'AllowCreate' => true )
						}
					}
				}
			end

			builder.to_xml
		end

		def self.sign_request(xml, private_key_file, certificate_file)
			doc = SignedXml::Document(xml)
			private_key = OpenSSL::PKey::RSA.new(File.new private_key_file)
			certificate = OpenSSL::X509::Certificate.new(File.read certificate_file)
			doc.sign(private_key, certificate)
			doc.to_xml
		end

	  	def self.saml_call(req)
	  		@sso_client.call( 'GetSSO', soap_action: 'urn:up-us:sso-service:service:v1/ISSOService/GetSSO', xml: req ).to_xml
	  	end

		def self.justin
			puts "Hey Justin this worked"
		end

	  	def self.check_resp(resp_doc)
	  		status = resp_doc.xpath('//Status//StatusCode')[0]['Value']

	  		if status.casecmp('urn:oasis:names:tc:SAML:2.0:status:Success') != 0
	  			raise status
	  		end
	  	end

end
