class ScoresController < ApplicationController
  before_action :set_score, only: [:show, :edit, :update, :destroy]

  # GET /scores
  # GET /scores.json
  def index
    @exercise_cnt = 2
    @exercise_stats = exercises(@exercise_cnt)
  end

  # GET /scores/1
  # GET /scores/1.json
  def show
  end

  # GET /scores/new
  def new
    @score = Score.new
  end

  # GET /scores/1/edit
  def edit
  end

  # POST /scores
  # POST /scores.json
  def create
    @score = Score.new(score_params)

    respond_to do |format|
      if @score.save
        format.html { redirect_to @score, notice: 'Score was successfully created.' }
        format.json { render :show, status: :created, location: @score }
      else
        format.html { render :new }
        format.json { render json: @score.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /scores/1
  # PATCH/PUT /scores/1.json
  def update
    respond_to do |format|
      if @score.update(score_params)
        format.html { redirect_to @score, notice: 'Score was successfully updated.' }
        format.json { render :show, status: :ok, location: @score }
      else
        format.html { render :edit }
        format.json { render json: @score.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /scores/1
  # DELETE /scores/1.json
  def destroy
    @score.destroy
    respond_to do |format|
      format.html { redirect_to scores_url, notice: 'Score was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def exercise(nro)
    tehtava = "mluukkai/ruby-tehtava#{nro}"

    repo = Travis::Repository.find(tehtava)

    pull_requests = {}

    repo.each_build do |build|
      if build.pull_request_number
        unless pull_requests[build.pull_request_number]
          pull_requests[build.pull_request_number] = []
        end
        pull_requests[build.pull_request_number] << build.state
      end
    end

    auth = {
      :username => ENV['USERNAME'],
      :password => ENV['PASSWORD']
    }
    url = "https://api.github.com/repos/#{tehtava}/pulls"
    response = HTTParty.get(url, :basic_auth => auth).parsed_response

    pull_request_users = {}

    response.each do |pr|
      pull_request_users[pr['number']] = pr['user']['login']
    end

    user_exercise = {}

    pull_requests.keys.each do |pr|
      user_exercise[pull_request_users[pr]] = pull_requests[pr].include?('passed')
    end

    puts "----"
    puts nro
    puts user_exercise

    user_exercise
  end

  def exercises(exercise_cnt)
    users = []

    (1..exercise_cnt).each do |cnt|
      users << exercise(cnt).keys
    end

    users = users.uniq

    user_exercises = {}

    (1..exercise_cnt).each do |cnt|
      exercise(cnt).each do |user, status|
        puts "#{user} #{status} #{exercise_cnt}"
        user_exercises[user] = {} unless user_exercises[user]
        user_exercises[user][cnt] = status
      end
    end

    user_exercises
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_score
      @score = Score.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def score_params
      params.require(:score).permit(:name)
    end
end
