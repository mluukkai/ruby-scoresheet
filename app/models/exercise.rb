class Exercise
  def self.exercise(nro)
    repository = "#{Conf.repository}#{nro}"

    travis_repo = Travis::Repository.find(repository)

    pull_requests = {}

    travis_repo.each_build do |build|
      puts build.state
      puts build.pull_request_number
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
        user_exercise[pull_request_users[pr]] = pull_requests[pr].include?('passed')
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
end