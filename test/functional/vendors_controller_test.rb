require 'test_helper'

class VendorsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    collection_fixtures('vendors', '_id')
    collection_fixtures('query_cache', 'test_id')
    collection_fixtures('measures')
    collection_fixtures('users')
    collection_fixtures('records', '_id')
    
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in User.first(:conditions => {:username => 'bobbytables'})
  end
  
  test "index" do
    get :index
    assert_response :success
    assert assigns(:complete_vendors).empty?
    assert assigns(:incomplete_vendors).size == 1
  end
  
  test "create" do
    assert Vendor.count == 1
    post(:create, {:vendor => {:name => 'An EHR', :measure_ids => ['0004', '0055'], :patient_population_id => 'all'}})
    assert_response :redirect
    assert Vendor.count == 2
  end
  
  test "Delete vendors and take their associated records with them" do
    assert_equal(1, Vendor.count)
    assert_equal(1, Record.count)
    
    vendor_id = Vendor.first.id
    
    Record.first.update_attribute(:test_id, vendor_id)
    
    post(:destroy, {:id => vendor_id})
    
    assert_equal(0, Vendor.count)
    assert_equal(0, Record.count)
    assert_response :redirect
  end
end
