class Conf < ActiveRecord::Base
  def self.exercises
    self.last.exercise_count
  end

  def self.repository
    self.last.repository_base
  end
end
