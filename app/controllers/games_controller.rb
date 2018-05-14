require 'open-uri'
require 'json'
class GamesController < ApplicationController
  def new
    @letters = [*("A".."Z")].sample(10)
    @start_time = Time.now
    @attempt = params[:attempt]
  end

  def score
    end_time = Time.now
    start_time = DateTime.parse(params[:start_time])
    @time_taken = (end_time - start_time).round(2)
    @attempt = params[:attempt]
    @grid = params[:grid].chars
    @results = score_and_message(@attempt, @grid, @time_taken)
  end

  private

  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def compute_score(attempt, time_taken)
    (time_taken > 60.0) ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end

  def score_and_message(attempt, grid, time)
    if included?(attempt.upcase, grid)
      if english_word?(attempt)
        score = compute_score(attempt, time)
        [score.round(2), "well done"]
      else
        [0, "not an english word"]
      end
    else
      [0, "not in the grid"]
    end
  end

  def english_word?(word)
    response = open("https://wagon-dictionary.herokuapp.com/#{word}")
    json = JSON.parse(response.read)
    return json['found']
  end
end
