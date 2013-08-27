class Assignment < ActiveRecord::Base

  # Model Validation
  validates_presence_of :project_id, :list_name

  # Model Relationships
  belongs_to :project
  belongs_to :user

  # Assignment Methods

  def randomization_number
    self.project.randomizations.order(:randomized_at).pluck(:id).index(self.id) + 1 rescue nil
  end

end
