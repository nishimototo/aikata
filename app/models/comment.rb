class Comment < ApplicationRecord
  validates :comment, presence: true, length: {maximum: 100}
  validates :rate, presence: true, numericality: {
    less_than_or_equal_to: 3,
    greater_than_or_equal_to: 1
  }

  belongs_to :user
  belongs_to :answer
end
