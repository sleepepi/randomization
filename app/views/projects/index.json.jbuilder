json.array!(@projects) do |project|
  json.extract! project, :name, :description, :user_id, :deleted
  json.url project_url(project, format: :json)
end
