json.array!(@assignments) do |assignment|
  json.extract! assignment, :project_id, :list_name, :block_group, :multiplier, :position, :treatment_arm, :subject_code, :randomized_at
  json.url assignment_url(assignment, format: :json)
end
