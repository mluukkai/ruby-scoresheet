require 'test_helper'

class ConfsControllerTest < ActionController::TestCase
  setup do
    @conf = confs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:confs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create conf" do
    assert_difference('Conf.count') do
      post :create, conf: { exercise_count: @conf.exercise_count, repository_base: @conf.repository_base }
    end

    assert_redirected_to conf_path(assigns(:conf))
  end

  test "should show conf" do
    get :show, id: @conf
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @conf
    assert_response :success
  end

  test "should update conf" do
    patch :update, id: @conf, conf: { exercise_count: @conf.exercise_count, repository_base: @conf.repository_base }
    assert_redirected_to conf_path(assigns(:conf))
  end

  test "should destroy conf" do
    assert_difference('Conf.count', -1) do
      delete :destroy, id: @conf
    end

    assert_redirected_to confs_path
  end
end
