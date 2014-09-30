class Artist < ActiveRecord::Base
  has_many :tracks
  has_many :quizzes
  has_many :taken_quizzes

  validates :tracks, :length => { :minimum => 25 }
end
