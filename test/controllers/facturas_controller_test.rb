require "test_helper"

class FacturasControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get facturas_index_url
    assert_response :success
  end

  test "should get show" do
    get facturas_show_url
    assert_response :success
  end

  test "should get new" do
    get facturas_new_url
    assert_response :success
  end

  test "should get create" do
    get facturas_create_url
    assert_response :success
  end

  test "should get edit" do
    get facturas_edit_url
    assert_response :success
  end

  test "should get update" do
    get facturas_update_url
    assert_response :success
  end

  test "should get destroy" do
    get facturas_destroy_url
    assert_response :success
  end

  test "should get pdf" do
    get facturas_pdf_url
    assert_response :success
  end
end
