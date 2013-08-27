class Assignment < ActiveRecord::Base

  # Model Validation
  validates_presence_of :project_id, :list_name

  # Model Relationships
  belongs_to :project
  belongs_to :user

end
