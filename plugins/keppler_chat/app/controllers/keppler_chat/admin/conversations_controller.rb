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
        @q = Conversation.ransack(params[:q])
        conversations = @q.result(distinct: true)
        @objects = conversations.page(@current_page).order(position: :asc)
        @total = conversations.size
        @conversations = @objects.all
        if !@objects.first_page? && @objects.size.zero?
          redirect_to conversations_path(page: @current_page.to_i.pred, search: @query)
        end
        respond_to do |format|
          format.html
          format.xls { send_data(@conversations.to_xls) }
          format.json { render :json => @objects }
        end
      end

      # GET /conversations/1
      def show
      end

      # GET /conversations/new
      def new
        @conversation = Conversation.new
      end

      # GET /conversations/1/edit
      def edit
      end

      # POST /conversations
      def create
        @conversation = Conversation.new(conversation_params)

        if @conversation.save
          redirect(@conversation, params)
        else
          render :new
        end
      end

      # PATCH/PUT /conversations/1
      def update
        if @conversation.update(conversation_params)
          redirect(@conversation, params)
        else
          render :edit
        end
      end

      def clone
        @conversation = Conversation.clone_record params[:conversation_id]

        if @conversation.save
          redirect_to admin_chat_conversations_path
        else
          render :new
        end
      end

      # DELETE /conversations/1
      def destroy
        @conversation.destroy
        redirect_to admin_chat_conversations_path, notice: actions_messages(@conversation)
      end

      def destroy_multiple
        Conversation.destroy redefine_ids(params[:multiple_ids])
        redirect_to(
          admin_conversations_path(page: @current_page, search: @query),
          notice: actions_messages(Conversation.new)
        )
      end

      def upload
        Conversation.upload(params[:file])
        redirect_to(
          admin_conversations_path(page: @current_page, search: @query),
          notice: actions_messages(Conversation.new)
        )
      end

      def download
        @conversations = Conversation.all
        respond_to do |format|
          format.html
          format.xls { send_data(@conversations.to_xls) }
          format.json { render json: @conversations }
        end
      end

      def reload
        @q = Conversation.ransack(params[:q])
        conversations = @q.result(distinct: true)
        @objects = conversations.page(@current_page).order(position: :desc)
      end

      def sort
        Conversation.sorter(params[:row])
        @q = Conversation.ransack(params[:q])
        conversations = @q.result(distinct: true)
        @objects = conversations.page(@current_page)
        render :index
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
