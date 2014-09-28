class QuizController < ApplicationController

  QUIZKEY = {
    0 => {difficulty: 0, source: 5, choices:  10},
    1 => {difficulty: 1, source: 5, choices:  15 },
    2 => {difficulty: 2, source: 10, choices: 20 },
    3 => {difficulty: 3, source: 20, choices: 20 }
  }

  def create
    # artist & tracks, knows nothing of quiz
    if artist_created?(params[:id])
      artist = Artist.find_by(itunes_id: params[:id])
    else
      artist = Artist.new(artist_attribs_from_params(params))
      initialize_new_artist_tracks(artist, params[:list])
    end

    #need to create logic to see what to do with th quiz, whether to return a quiz, or to create new quiz
    if signed_in?
      if artist_created?(params[:id])
        if artist.quizzes.length > 0
          quiz = artist.quizzes.last
        else
          quiz = create_quiz(artist, QUIZKEY[1])
          artist.quizzes << quiz
        end
      end
    else
      quiz = create_quiz(artist, QUIZKEY[0])
    end

    render :json => create_frontend_quiz(artist, quiz.id)
  end

  def artist_attribs_from_params params
    { name: params[:name], itunes_id: params[:id] }
  end

  def track_attribs_from_params track_from_params
    {
      preview_url: track_from_params["previewUrl"],
      art_url: track_from_params["artworkUrl100"],
      name: track_from_params["trackName"]
    }
  end

  def stats
    if signed_in?
      user = User.find(session[:user_id])
      quiz_id = Question.find(params[:returnVals]['0'][:question].to_i).quiz_id
      answers = []
      times = []

      params[:returnVals].values.each do |x|

        new_answer = UserAnswer.create(
          question_id: x[:question].to_i,
          track_id: x[:track_id].to_i,
          response_time: x[:response_time].to_f
        )

        user.user_answers << new_answer
        answers << new_answer

        times << x[:response_time].to_f
      end
    end

    new_record = TakenQuiz.create(quiz_id: quiz_id, time: times.reduce(:+), score: user.quiz_score(quiz_id, answers, times ) )
    user.taken_quizzes << new_record

    render :json => new_record.score

  end

end
