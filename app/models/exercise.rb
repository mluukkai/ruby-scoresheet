class Exercise
  def self.exercise(nro)
    repository = "#{Conf.repository}#{nro}"

    client = Travis::Client.new
    client.clear_cache
    travis_repo = client.repo(repository)

    pull_requests = {}

    travis_repo.each_build do |build|
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
    url = "https://api.github.com/repos/#{repository}/pulls"
    response = HTTParty.get(url, :basic_auth => auth).parsed_response

    pull_request_users = {}

    response.each do |pr|
      pull_request_users[pr['number']] = pr['user']['login']
    end

    user_exercise = {}

    pull_requests.keys.each do |pr|
      if pull_request_users[pr]
        user_exercise[pull_request_users[pr]] = status(pull_requests[pr])
      end
    end

    user_exercise
  end

  def self.all
    exercise_numbers = (1..Conf.exercises)

    exercises = {}
    exercise_numbers.each do |number|
      exercises[number] = exercise(number)
    end

    users = []
    exercise_numbers.each do |number|
      users << exercises[number].keys
    end

    users = users.uniq

    user_exercises = {}

    exercise_numbers.each do |number|
      exercises[number].each do |user, status|
        user_exercises[user] = {} unless user_exercises[user]
        user_exercises[user][number] = status
      end
    end

    user_exercises
  end

  def self.status(pull_request)
    return "pass" if pull_request.include?('passed')
    return "testing" if pull_request.include?('started') or pull_request.include?('created')
    "fail"
  end
end