class CreateKepplerChatMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :keppler_chat_messages do |t|
      t.text :body
      t.references :user, foreign_key: true
      t.integer :conversation_id#, foreign_key: true
      t.integer :position
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :keppler_chat_messages, :deleted_at
    add_index :keppler_chat_messages, :conversation_id
  end
end
