class AddRandomizationRequirementsToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :randomization_requirements, :text
  end
end
