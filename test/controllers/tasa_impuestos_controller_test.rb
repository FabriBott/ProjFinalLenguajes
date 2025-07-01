require "test_helper"

class TasaImpuestosControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get tasa_impuestos_index_url
    assert_response :success
  end

  test "should get show" do
    get tasa_impuestos_show_url
    assert_response :success
  end

  test "should get new" do
    get tasa_impuestos_new_url
    assert_response :success
  end

  test "should get create" do
    get tasa_impuestos_create_url
    assert_response :success
  end

  test "should get edit" do
    get tasa_impuestos_edit_url
    assert_response :success
  end

  test "should get update" do
    get tasa_impuestos_update_url
    assert_response :success
  end

  test "should get destroy" do
    get tasa_impuestos_destroy_url
    assert_response :success
  end
end
