class Message < ApplicationRecord
  belongs_to :user
  belongs_to :room
  
  validates :body, length: { minimum: 1, maximum: 140 }
end
