require 'test_helper'

class SessionControllerTest < ActionController::TestCase
  test "should get start" do
    get :start
    assert_response :success
  end

  test "should get join" do
    get :join
    assert_response :success
  end

  test "should get midpoint" do
    get :midpoint
    assert_response :success
  end

end
