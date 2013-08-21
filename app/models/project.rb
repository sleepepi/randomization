class Project < ActiveRecord::Base

  # Concerns
  include Deletable, Searchable

  # Named Scopes

  # Model Validation
  validates_presence_of :name, :user_id

  # Model Relationships
  belongs_to :user

end
