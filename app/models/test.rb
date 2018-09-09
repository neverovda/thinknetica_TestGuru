class Test < ApplicationRecord
  
  belongs_to :author, class_name: 'User'
  belongs_to :category
  
  has_many :questions, dependent: :destroy
  has_many :test_passages, dependent: :destroy
  has_many :users, through: :test_passages

  validates :title, presence: true, uniqueness: { scope: :level }
  validates :level, numericality: { only_integer: true,
                                    greater_than_or_equal_to: 0 }
  
  scope :by_level, -> (level) { where(level: level) }
  scope :easy, -> { by_level(0..1) }
  scope :medium, -> { by_level(2..4) }
  scope :hard, -> { by_level(5..Float::INFINITY) }

  scope :tests_by_category, -> (category) { joins(:category).
                                            where(categories: {title: category}) }
  scope :order_desc, -> { order(title: :desc) } 

  def self.by_category(category)
    tests_by_category(category).order_desc.pluck(:title)                   
  end

end
