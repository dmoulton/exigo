require 'savon'

class Exigo
  attr_accessor :username,:password,:company,:wsdl,:namespacer
  
  def initialize(username,password,company)
    @username  = username
    @password  = password
    @company   = company
    @wsdl      = "http://api.exigo.com/3.0/ExigoApi.asmx?WSDL"
    @namespacer = "http://api.exigo.com/"
  end
  
  def method_missing(name, *args, &block)
    client = Savon::Client.new @wsdl
    ns = @namespacer
    auth   = { "api:LoginName"=>@username, "api:Password"=>@password, "api:Company"=>@company }
    payload = args[0].each_with_object({}) { |(k,v), h| h["api:#{k}"] = v }
    action = name.to_s.camelcase
    
    response = client.request "api:#{action}Request" do
      http.headers["SOAPAction"] = "\"#{ns}#{action}\"" 
      soap.namespaces["xmlns:env"] = "http://schemas.xmlsoap.org/soap/envelope/"
      soap.namespaces["xmlns:api"] = ns
      soap.header = { "api:ApiAuthentication" => auth }
      soap.body = payload
    end
    response.to_hash["#{name}_result".to_sym]
    #response.to_hash
  end
end
