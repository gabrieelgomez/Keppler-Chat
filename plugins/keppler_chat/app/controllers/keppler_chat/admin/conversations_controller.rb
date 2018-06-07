require_dependency "keppler_chat/application_controller"
module KepplerChat
  module Admin
    # ConversationsController
    class ConversationsController < ApplicationController
      layout 'keppler_chat/admin/layouts/application'
      before_action :set_conversation, only: [:show, :edit, :update, :destroy]
      before_action :show_history, only: [:index]
      before_action :set_attachments
      before_action :authorization
      include KepplerChat::Concerns::Commons
      include KepplerChat::Concerns::History
      include KepplerChat::Concerns::DestroyMultiple


      # GET /conversations
      def index

        session[:conversations] ||= []

        @users = User.all.where.not(id: current_user)
        @conversations = Conversation.includes(:recipient, :messages)
                                     .find(session[:conversations]) rescue nil

        @q = Conversation.ransack(params[:q])
        conversations = @q.result(distinct: true)
        @objects = conversations.page(@current_page).order(position: :asc)
        @total = conversations.size
        # @conversations = @objects.all
        # if !@objects.first_page? && @objects.size.zero?
        #   redirect_to conversations_path(page: @current_page.to_i.pred, search: @query)
        # end
        # respond_to do |format|
        #   format.html
        #   format.xls { send_data(@conversations.to_xls) }
        #   format.json { render :json => @objects }
        # end
      end


      # POST /conversations
      def create
        @conversation = Conversation.get(current_user.id, params[:user_id])
        add_to_conversations unless conversated?
      end

      private

      def authorization
        authorize Conversation
      end

      def set_attachments
        @attachments = ['logo', 'brand', 'photo', 'avatar', 'cover', 'image',
                        'picture', 'banner', 'attachment', 'pic', 'file']
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_conversation
        @conversation = Conversation.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def conversation_params
        params.require(:conversation).permit(:recipient_id, :sender_id, :position, :deleted_at)
      end

      def show_history
        get_history(Conversation)
      end

      def get_history(model)
        @activities = PublicActivity::Activity.where(
          trackable_type: model.to_s
        ).order('created_at desc').limit(50)
      end

      # Get submit key to redirect, only [:create, :update]
      def redirect(object, commit)
        if commit.key?('_save')
          redirect_to([:admin, :chat, object], notice: actions_messages(object))
        elsif commit.key?('_add_other')
          redirect_to(
            send("new_admin_chat_#{underscore(object)}_path"),
            notice: actions_messages(object)
          )
        end
      end
    end
  end
end
