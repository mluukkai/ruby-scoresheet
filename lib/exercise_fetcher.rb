class ExerciseFetcher

  def initialize
    @auth = "#{ENV["USERNAME"]}:#{ENV["PASSWORD"]}"
  end


  def find_exercise_data(num)
    exercise = "mluukkai/ruby-tehtava#{num}"
    travis_pulls = find_pulls_travis exercise

    pull_users = pull_request_users pull_requests('mluukkai', "ruby-tehtava#{num}")
    user_exercises(travis_pulls, pull_users)
  end

  def user_exercises(pull_requests, pull_users)
    exercises = {}

    pull_requests.each do |pr, status|
      exercises[pull_users[pr]] = status(pull_requests[pr])
    end

    exercises
  end

  def pull_request_users(pull_requests)
    requests = {}
    pull_requests.each do |pr|
      requests[pr['number']] = pr['user']['login']
    end
    requests
  end

  def find_pulls_travis(exercise)
    repo = Travis::Repository.find exercise
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
    github = Github.new user: user, repo: repo
    github.pull_requests.list
  end

  def status(pull_request)
    return "pass" if pull_request.include?('passed')
    return "testing" if pull_request.include?('started') or pull_request.include?('created')
    "fail"
  end
end
