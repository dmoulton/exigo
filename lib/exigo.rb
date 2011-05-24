require 'savon'

class Exigo
  attr_accessor :username,:password,:company,:wsdl,:namespacer, :transaction_details
  
  def initialize(username,password,company)
    @username  = username
    @password  = password
    @company   = company
    @wsdl      = "http://api.exigo.com/3.0/ExigoApi.asmx?WSDL"
    @namespacer = "http://api.exigo.com/"
  end
  
  def method_missing(name, *args, &block)
    payload = args[0].each_with_object({}) { |(k,v), h| h["api:#{k}"] = v }

    make_request(name,payload)
  end

  # Not yet complete
  def new_order(shipping_info,order_properties,distributor_id,create_customer=true, test=false)
    ship_to = {"api:FirstName" => shipping_info["api:FirstName"],
                "api:LastName"  => shipping_info["api:LastName"],
                "api:Email" => shipping_info["api:Email"],
                "api:Phone" => shipping_info["api:Phone"],
                "api:Address1" => shipping_info["api:MainAddress1"],
                "api:City" => shipping_info["api:MainCity"],
                "api:State" => shipping_info["api:MainState"],
                "api:Zip" => shipping_info["api:MainZip"],
                "api:Country" => shipping_info["api:MainCountry"],

                }
    ret = { :success => true }
    order_id = nil
    begin
      if create_customer
        cc_res = make_request("create_customer", shipping_info)

        ret[:new_customer_id] = cc_res[:customer_id]

        order_info = ship_to.merge(order_properties)

        order_res = make_request("create_order",order_info)
        ret[:order_id] = order_res[:order_id]
      end
    rescue Exception=>e
      ret[:success] = false
      ret[:error] = e.to_s

      if ret[:order_id]

        #TODO: cancel order if there is an error after its created
      end
    end

    ret
  end

  protected

  def make_request(name,payload)
    client = Savon::Client.new @wsdl
    ns = @namespacer
    auth   = { "api:LoginName"=>@username, "api:Password"=>@password, "api:Company"=>@company }
    action = name.to_s.camelcase

    response = client.request "api:#{action}Request" do
      http.headers["SOAPAction"] = "\"#{ns}#{action}\""
      soap.namespaces["xmlns:env"] = "http://schemas.xmlsoap.org/soap/envelope/"
      soap.namespaces["xmlns:api"] = ns
      soap.header = { "api:ApiAuthentication" => auth }
      soap.body = payload
    end

    response.to_hash["#{name}_result".to_sym]
  end
end
