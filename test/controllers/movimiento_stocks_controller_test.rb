require "test_helper"

class MovimientoStocksControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get movimiento_stocks_index_url
    assert_response :success
  end

  test "should get show" do
    get movimiento_stocks_show_url
    assert_response :success
  end

  test "should get new" do
    get movimiento_stocks_new_url
    assert_response :success
  end

  test "should get create" do
    get movimiento_stocks_create_url
    assert_response :success
  end
end
