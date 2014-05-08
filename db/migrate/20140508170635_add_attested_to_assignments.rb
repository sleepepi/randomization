class AddAttestedToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :attested, :boolean, null: false, default: false
  end
end
