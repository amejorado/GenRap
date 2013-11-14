class EmailController < ApplicationController
	
	def send_simple_message
		RestClient.post "https://api:key-4e3j9-vt6dvv9al93usavq800of2j6l3@api.mailgun.net/v2/mg.scitus.mx/messages",
		:from => "Excited User <info@codigofeliz.com>",
		:to => "rms.julle@gmail.com",
		:subject => "Prueba Correo Codea Feliz",
		:text => "Testing some Mailgun awesomness!"
    end
end