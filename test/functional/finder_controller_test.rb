require 'test_helper'

class FinderControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get result" do
    get :result
    assert_response :success
  end

  test "should get find" do
    get :find
    assert_response :success
  end

  test "should get filter" do
    get :filter
    assert_response :success
  end

end
