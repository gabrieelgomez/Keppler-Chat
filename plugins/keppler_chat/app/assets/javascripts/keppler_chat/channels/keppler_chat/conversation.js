App.conversation = App.cable.subscriptions.create("KepplerChat::ConversationChannel", {
  connected: function() {},
  disconnected: function() {},
  received: function(data) {
    var conversation = $('#conversations-list').find("[data-conversation-id='" + data['conversation_id'] + "']");
    conversation.find('.direct-chat-messages').find('ul').append(data['message']);
    var messages_list = conversation.find('.direct-chat-messages');
    var height = messages_list[0].scrollHeight;
    messages_list.scrollTop(height);
  },
  speak: function(message) {
    return this.perform('speak', {
      message: message
    });
  }
});
$(document).on('submit', '.new_message', function(e) {
  e.preventDefault();
  var values = $(this).serializeArray();
  console.log('values', values);
  App.conversation.speak(values);
  $(this).trigger('reset');
});
