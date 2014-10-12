require 'test_helper'

class MediaContentsControllerTest < ActionController::TestCase
  setup do
    @media_content = media_contents(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:media_contents)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create media_content" do
    assert_difference('MediaContent.count') do
      post :create, media_content: { file_name: @media_content.file_name }
    end

    assert_redirected_to media_content_path(assigns(:media_content))
  end

  test "should show media_content" do
    get :show, id: @media_content
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @media_content
    assert_response :success
  end

  test "should update media_content" do
    patch :update, id: @media_content, media_content: { file_name: @media_content.file_name }
    assert_redirected_to media_content_path(assigns(:media_content))
  end

  test "should destroy media_content" do
    assert_difference('MediaContent.count', -1) do
      delete :destroy, id: @media_content
    end

    assert_redirected_to media_contents_path
  end
end
