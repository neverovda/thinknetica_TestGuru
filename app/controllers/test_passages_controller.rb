class TestPassagesController < ApplicationController

  before_action :authenticate_user!
  before_action :find_test_passage, only: %i[show update result gist]

  def show
  end
  
  def result
  end

  def update
    @test_passage.accept!(params[:answers_ids])
    
    if @test_passage.completed? || @test_passage.time_over?
      TestsMailer.completed_test(@test_passage).deliver_now
      
      badges = RewardingServise.new(@test_passage).call
      if badges.present?
        current_user.badges.push(badges)
        names = badges.map(&:name).join(', ')
        flash[:notice] = "Получены награды: #{names}."
      end    

      redirect_to result_test_passage_path(@test_passage)
    else
      redirect_to test_passage_path(@test_passage) 
    end  
  end

  def gist
    
    result = GistQuestionService.new(@test_passage.current_question).call

    flash_options = if result.success?
      current_user.gists.create(question: @test_passage.current_question,
                                gist_hash: result.gist_hash)
      { notice: t('.success'), flash: { gist_hash: result.gist_hash } }
    else
      { alert: t('.failure') }
    end

    redirect_to @test_passage, flash_options
  end

  private

  def find_test_passage
    @test_passage = TestPassage.find(params[:id])
  end  

end
