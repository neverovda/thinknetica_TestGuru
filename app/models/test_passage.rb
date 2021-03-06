class TestPassage < ApplicationRecord

  belongs_to :user
  belongs_to :test
  belongs_to :current_question, class_name: 'Question', optional: true

  before_validation :before_validation_next_question
  before_save :mark_successful

  scope :by_category, -> (category) { joins(:test).
                                            where(tests: {category: category}) }

  scope :by_level, -> (level) { joins(:test).
                                      where(tests: {level: level}) }
  
  def completed?
    current_question.nil?
  end  

  def accept!(answers_ids)
    self.correct_questions += 1 if correct_answer?(answers_ids) && time_not_over?
    save!
  end

  def time_over?
    if test.whithout_timer?
      false
    else  
      Time.current >  end_time + 3.seconds
    end  
  end

  def time_not_over?
    !time_over?
  end

  def seconds_left
    if time_not_over? 
      (end_time - Time.current).to_i
    else
      0
    end    
  end  

  def total_percanteges
    (correct_questions.to_f/test.questions.size * 100).round
  end  
    
  def success?
    total_percanteges >= 85
  end

  def amount_questions
    test.questions.size
  end  

  def number_of_current_question
    amount_questions - unanswered_questions.size  
  end

  def amount_completed_questions
    number_of_current_question - 1 
  end

  private

  def correct_answer?(answers_ids)
    correct_answers.ids.sort == Array(answers_ids).map(&:to_i).sort
  end

  def correct_answers
    current_question.answers.only_correct
  end

  def before_validation_next_question
    self.current_question = next_question
  end

  def next_question
    if current_question.nil? 
      test.questions.first if test.present?
    else 
      unanswered_questions.first
    end  
  end

  def unanswered_questions
    test.questions.order(:id).where('id > ?', current_question.id)  
  end

  def mark_successful
    self.success = completed? && success? 
  end

  def end_time  
    @end_time ||= self.created_at + test.time.minutes
  end
  
end
