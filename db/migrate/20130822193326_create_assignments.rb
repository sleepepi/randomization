class CreateAssignments < ActiveRecord::Migration
  def change
    create_table :assignments do |t|
      t.integer :project_id
      t.string :list_name
      t.integer :block_group
      t.integer :multiplier
      t.integer :position
      t.string :treatment_arm
      t.string :subject_code
      t.datetime :randomization_at

      t.timestamps
    end
  end
end
