# Conversation Model
module KepplerChat
  class Conversation < ActiveRecord::Base
    include ActivityHistory
    include CloneRecord
    require 'csv'
    acts_as_list

    has_many :messages, dependent: :destroy
    belongs_to :sender, foreign_key: :sender_id, class_name: 'User'
    belongs_to :recipient, foreign_key: :recipient_id, class_name: 'User'

    validates :sender_id, uniqueness: { scope: :recipient_id }

    scope :between, -> (sender_id, recipient_id) do
      where(sender_id: sender_id, recipient_id: recipient_id).or(
        where(sender_id: recipient_id, recipient_id: sender_id)
      )
    end

    def self.get(sender_id, recipient_id)
      conversation = between(sender_id, recipient_id).first
      return conversation if conversation.present?

      create(sender_id: sender_id, recipient_id: recipient_id)
    end

    def opposed_user(user)
      user == recipient ? sender : recipient
    end

    # Fields for the search form in the navbar
    def self.search_field
      fields = ["recipient_id", "sender_id", "position", "deleted_at"]
      build_query(fields, :or, :cont)
    end

    def self.upload(file)
      CSV.foreach(file.path, headers: true) do |row|
        begin
          self.create! row.to_hash
        rescue => err
        end
      end
    end

    def self.sorter(params)
      params.each_with_index do |id, idx|
        self.find(id).update(position: idx.to_i+1)
      end
    end

    # Funcion para armar el query de ransack
    def self.build_query(fields, operator, conf)
      query = fields.join("_#{operator}_")
      query << "_#{conf}"
      query.to_sym
    end
  end
end
