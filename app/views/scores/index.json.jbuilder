json.array!(@scores) do |score|
  json.extract! score, :id, :name
  json.url score_url(score, format: :json)
end
