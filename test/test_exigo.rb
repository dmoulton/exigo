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
end
