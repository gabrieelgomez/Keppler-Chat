require "application_system_test_case"

module KepplerChat
  class ConversationsTest < ApplicationSystemTestCase
    setup do
      @conversation = keppler_chat_conversations(:one)
    end

    test "visiting the index" do
      visit conversations_url
      assert_selector "h1", text: "Conversations"
    end

    test "creating a Conversation" do
      visit conversations_url
      click_on "New Conversation"

      fill_in "Deleted At", with: @conversation.deleted_at
      fill_in "Position", with: @conversation.position
      fill_in "Recipient", with: @conversation.recipient_id
      fill_in "Sender", with: @conversation.sender_id
      click_on "Create Conversation"

      assert_text "Conversation was successfully created"
      click_on "Back"
    end

    test "updating a Conversation" do
      visit conversations_url
      click_on "Edit", match: :first

      fill_in "Deleted At", with: @conversation.deleted_at
      fill_in "Position", with: @conversation.position
      fill_in "Recipient", with: @conversation.recipient_id
      fill_in "Sender", with: @conversation.sender_id
      click_on "Update Conversation"

      assert_text "Conversation was successfully updated"
      click_on "Back"
    end

    test "destroying a Conversation" do
      visit conversations_url
      page.accept_confirm do
        click_on "Destroy", match: :first
      end

      assert_text "Conversation was successfully destroyed"
    end
  end
end
