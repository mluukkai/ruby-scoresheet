json.array!(@confs) do |conf|
  json.extract! conf, :id, :exercise_count, :repository_base
  json.url conf_url(conf, format: :json)
end
