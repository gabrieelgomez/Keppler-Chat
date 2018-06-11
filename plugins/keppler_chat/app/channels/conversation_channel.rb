# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class ConversationChannel < ApplicationCable::Channel
  def subscribed
    Rails.logger.debug("Messages FOLLOW")
    stream_from "conversations-#{current_user.id}"
  end

  def unsubscribed
    stop_all_streams
  end

  def speak(data)
    message_params = data['message'].each_with_object({}) do |el, hash|
      hash[el.values.first] = el.values.last
    end

    # KepplerChat::Message.create! body: message_params['body'], user_id: message_params['user_id'], conversation_id: message_params['conversation_id']
    #ActionCable.server.broadcast 'conversation_channel', message: render_message(message_params['body'])

    ActionCable.server.broadcast(
      "conversations-#{current_user.id}",
      message: message_params
    )
  end

  # private
  #
  # def render_message(message)
  #   ApplicationController.renderer.render(partial: 'keppler_chat/admin/conversations/message',
  #                                          locals: { message: message })
  # end

end
