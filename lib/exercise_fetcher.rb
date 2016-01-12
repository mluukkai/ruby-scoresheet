class ExerciseFetcher

  def initialize
    @auth = auth
  end

  def auth
    if ENV["USERNAME"].present? and ENV["PASSWORD"].present? then
      "#{ENV["USERNAME"]}:#{ENV["PASSWORD"]}"
    end
  end

  def find_users(exercises)
      users = Array.new
      Conf.exercises.downto 1 do |i|
        users << exercises[i].keys
      end
      users.uniq
    end

  def find_exercises
    exercises = Hash.new
    Conf.exercises.downto 1 do |i|
      exercises[i] = find_exercise_data i
    end
    exercises
  end

  def all
    user_exercises = Hash.new
    exercises = find_exercises
    users = find_users exercises

    Conf.exercises.downto 1 do |number|
      exercises[number].each do |user, status|
        if user.present? then
          user_exercises[user] = {} unless user_exercises[user]
          user_exercises[user][number] = status
        end
      end
    end

    user_exercises
  end


  def find_exercise_data(num)
    repo = "#{Conf.repository}#{num}"
    travis_pulls = find_pulls_travis repo

    pull_users = pull_request_users pull_requests(get_user, get_repo(num))
    user_exercises(travis_pulls, pull_users)
  end

  def user_exercises(pull_requests, pull_users)
    exercises = {}

    pull_requests.each do |pr, status|
      unless exercises[pull_users[pr]] == 'pass'
        exercises[pull_users[pr]] = status(pull_requests[pr])
      end
    end

    exercises
  end

  def pull_request_users(pull_requests)
    requests = {}
    pull_requests.each do |pr|
      if pr['user']['login'].present? then
        requests[pr['number']] = pr['user']['login']
      end
    end
    requests
  end

  def find_pulls_travis(repository)
    client = Travis::Client.new
    client.clear_cache
    repo = client.repo(repository)

    pull_requests = {}

    repo.each_build do |build|
      if build.pull_request_number
        unless pull_requests[build.pull_request_number]
          pull_requests[build.pull_request_number] = []
        end
        pull_requests[build.pull_request_number] << build.state
      end
    end
    pull_requests
  end

  def pull_requests(user, repo)
    github = Github.new user: user, repo: repo, basic_auth: @auth
    github.pull_requests.list
  end

  def get_user
    Conf.repository.split("\/").first
  end

  def get_repo(num)
    Conf.repository.split("\/").second+num.to_s
  end

  def status(pull_request)
    return "pass" if pull_request.include?('passed')
    return "testing" if pull_request.include?('started') or pull_request.include?('created')
    "fail"
  end

  private :get_user, :get_repo, :status, :pull_requests

end
