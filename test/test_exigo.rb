require 'helper'

class TestExigo < Test::Unit::TestCase
  should "get customer info" do
    x = Exigo.new(API_USERNAME,API_PASSWORD,API_COMPANY)
    res = x.get_customers(:CustomerID => EXIGO_ID)
    assert res[:result][:status] == "Success"
  end

	should "log in a user" do
    conn = Exigo.new(API_USERNAME,API_PASSWORD,API_COMPANY)
    res = conn.login_customer(:LoginName=>EXIGO_USERNAME,:Password=>EXIGO_PASSWORD)
    assert res[:result][:status] == "Success"

    res = conn.get_login_session(:SessionID=>res[:session_id])
    assert res[:result][:status] == "Success"
    assert_equal EXIGO_ID.to_s, res[:customer_id]
  end

  should "create a new customer and a new order in exigo" do
    conn = Exigo.new(API_USERNAME,API_PASSWORD,API_COMPANY)

    customer = {"api:FirstName" => "Test",
                "api:LastName"  => "User",
                "api:CustomerType" => "10",
                "api:Email" => "test3254@example.com",
                "api:Phone" => "8015551212",
                "api:MainAddress1" => "123 Main St",
                "api:MainCity" => "Salt Lake City",
                "api:MainState" => "UT",
                "api:MainZip" => "84001",
                "api:MainCountry" => "US",
                "api:CanLogin" => false,
                "api:EnrollerID" => EXIGO_ID,
                "api:InsertEnrollerTree" => "true",
                "api:SponsorID" => EXIGO_ID,
                "api:InsertUnilevelTree" => "true"
                }

    order_properties = { "api:CustomerID" => EXIGO_ID,
                         "api:OrderStatus" => "CCPending",
                         "api:CurrencyCode" => "usd",
                         "api:OrderType" => "APIOrder",
                         "api:OrderDate" => Time.now,
                          "api:WarehouseID" => 5,
                          "api:ShipMethodID" => 6,
                          "api:PriceType" => 1,
                          "api:Details" => { "api:OrderDetailRequest" => { "api:ItemCode" => "OSM-GIFT","api:Quantity" => 1 } } }

    res = conn.new_order(customer,order_properties, EXIGO_ID, true, true)
    assert_equal true,res[:success]
    puts res.inspect

    c = conn.get_customers(:CustomerID => res[:new_customer_id])
    assert_equal("test3254@example.com",c[:customers][:customer_response][:email], "New customer not correct")

    # delete user
    if (res[:new_customer_id])
      d = conn.update_customer(:CustomerID => res[:new_customer_id], :CustomerStatus => 0)
      assert_equal "Success", d[:result][:status]
    end


  end
end
