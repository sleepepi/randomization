class AddRandomizationGoalToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :randomization_goal, :integer, null: false, default: 0
  end
end
