require 'test_helper'

module KepplerChat
  class ConversationsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @conversation = keppler_chat_conversations(:one)
    end

    test "should get index" do
      get conversations_url
      assert_response :success
    end

    test "should get new" do
      get new_conversation_url
      assert_response :success
    end

    test "should create conversation" do
      assert_difference('Conversation.count') do
        post conversations_url, params: { conversation: { deleted_at: @conversation.deleted_at, position: @conversation.position } }
      end

      assert_redirected_to conversation_url(Conversation.last)
    end

    test "should show conversation" do
      get conversation_url(@conversation)
      assert_response :success
    end

    test "should get edit" do
      get edit_conversation_url(@conversation)
      assert_response :success
    end

    test "should update conversation" do
      patch conversation_url(@conversation), params: { conversation: { deleted_at: @conversation.deleted_at, position: @conversation.position } }
      assert_redirected_to conversation_url(@conversation)
    end

    test "should destroy conversation" do
      assert_difference('Conversation.count', -1) do
        delete conversation_url(@conversation)
      end

      assert_redirected_to conversations_url
    end
  end
end
