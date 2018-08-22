class CreateKepplerChatConversations < ActiveRecord::Migration[5.2]
  def change
    create_table :keppler_chat_conversations do |t|
      t.integer :recipient_id
      t.integer :sender_id
      t.integer :position
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :keppler_chat_conversations, :recipient_id
    add_index :keppler_chat_conversations, :sender_id
    add_index :keppler_chat_conversations, :deleted_at
    add_index :keppler_chat_conversations, [:recipient_id, :sender_id], unique: true
  end
end
