require_dependency "keppler_chat/application_controller"
module KepplerChat
  module Admin
    # MessagesController
    class MessagesController < ApplicationController
      layout 'keppler_chat/admin/layouts/application'
      before_action :set_message, only: [:show, :edit, :update, :destroy]
      before_action :show_history, only: [:index]
      before_action :set_attachments
      before_action :authorization
      include KepplerChat::Concerns::Commons
      include KepplerChat::Concerns::History
      include KepplerChat::Concerns::DestroyMultiple


      # GET /messages
      def index
        @q = Message.ransack(params[:q])
        messages = @q.result(distinct: true)
        @objects = messages.page(@current_page).order(position: :asc)
        @total = messages.size
        @messages = @objects.all
        if !@objects.first_page? && @objects.size.zero?
          redirect_to messages_path(page: @current_page.to_i.pred, search: @query)
        end
        respond_to do |format|
          format.html
          format.xls { send_data(@messages.to_xls) }
          format.json { render :json => @objects }
        end
      end

      # GET /messages/1
      def show
      end

      # GET /messages/new
      def new
        @message = Message.new
      end

      # GET /messages/1/edit
      def edit
      end

      # POST /messages
      def create
        @conversation = Conversation.includes(:recipient).find(params[:conversation_id])
        @message = @conversation.messages.create(message_params)
      end

      # PATCH/PUT /messages/1
      def update
        if @message.update(message_params)
          redirect(@message, params)
        else
          render :edit
        end
      end

      def clone
        @message = Message.clone_record params[:message_id]

        if @message.save
          redirect_to admin_chat_messages_path
        else
          render :new
        end
      end

      # DELETE /messages/1
      def destroy
        @message.destroy
        redirect_to admin_chat_messages_path, notice: actions_messages(@message)
      end

      def destroy_multiple
        Message.destroy redefine_ids(params[:multiple_ids])
        redirect_to(
          admin_messages_path(page: @current_page, search: @query),
          notice: actions_messages(Message.new)
        )
      end

      def upload
        Message.upload(params[:file])
        redirect_to(
          admin_messages_path(page: @current_page, search: @query),
          notice: actions_messages(Message.new)
        )
      end

      def download
        @messages = Message.all
        respond_to do |format|
          format.html
          format.xls { send_data(@messages.to_xls) }
          format.json { render json: @messages }
        end
      end

      def reload
        @q = Message.ransack(params[:q])
        messages = @q.result(distinct: true)
        @objects = messages.page(@current_page).order(position: :desc)
      end

      def sort
        Message.sorter(params[:row])
        @q = Message.ransack(params[:q])
        messages = @q.result(distinct: true)
        @objects = messages.page(@current_page)
        render :index
      end

      private

      def authorization
        authorize Message
      end

      def set_attachments
        @attachments = ['logo', 'brand', 'photo', 'avatar', 'cover', 'image',
                        'picture', 'banner', 'attachment', 'pic', 'file']
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_message
        @message = Message.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def message_params
        params.require(:message).permit(:body, :user_id, :conversation_id, :position, :deleted_at)
      end

      def show_history
        get_history(Message)
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
