require "erb"
require_relative "../../../codebreaker/codebreaker/lib/codebreaker/game"

class Racker
  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
    start_game
    possible_codes
    results
    hint
  end

  def response
    case @request.path
      when "/"
        Rack::Response.new(render("index.html.erb"))
      when "/make_attempt" then make_attempt
      when "/start_game" then start_game(true)
      when "/get_hint" then get_hint
      when "/final_form"
        Rack::Response.new(render("final_form.html.erb"))
      when "/save_results" then save_results
      when "/show_results"
        Rack::Response.new(render("show_results.html.erb"))
      else
      Rack::Response.new("Not Found", 404)
    end
  end

  def make_attempt
    @possible_codes << @request.params["possible_code"]

    @results << @game.guess_code(@request.params["possible_code"])

    if @game.win
      Rack::Response.new do |response|
        response.set_cookie("possible_codes", @possible_codes)
        response.set_cookie("results", @results)
        response.redirect("/final_form")
      end
    else
      if @game.attempts >= 1
        Rack::Response.new do |response|
          response.set_cookie("possible_codes", @possible_codes)
          response.set_cookie("results", @results)
          response.redirect("/")
        end
      else
        Rack::Response.new do |response|
          response.set_cookie("possible_codes", @possible_codes)
          response.set_cookie("results", @results)
          response.redirect("/final_form")
        end
      end
    end

  end

  def start_game(new_game = false)
    if new_game
      @game = @request.session[:game] = Codebreaker::Game.new
      Rack::Response.new do |response|
        response.set_cookie("possible_codes", [])
        response.set_cookie("results", [])
        response.set_cookie("hint", nil)
        response.redirect("/")
      end
    else
      @game = @request.session[:game] ||= Codebreaker::Game.new
    end
  end

  def get_hint
    @hint = @game.hint
    Rack::Response.new do |response|
      response.set_cookie("hint", @hint)
      response.redirect("/")
    end
  end

  def save_results
    @final_results = @request.session[:final_results]
    # @final_results << @possible_codes.last
    # @final_results << @game.attempts
    Rack::Response.new do |response|
      response.set_cookie("player_name", @request.params["player_name"])
      response.redirect("/show_results")
    end
  end

  def player_name
    @request.cookies["player_name"]
  end

  def hint
    @hint = @request.cookies["hint"] || []
    @hint = @hint.split('&').join unless @hint.is_a? Array
  end

  def possible_codes
    @possible_codes = @request.cookies["possible_codes"] || []
    @possible_codes = @possible_codes.split('&') unless @possible_codes.is_a? Array
  end

  def results
    @results = @request.cookies["results"] || []
    @results = @results.split('&') unless @results.is_a? Array
  end

  def render(template)
    path = File.expand_path("../views/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end

end