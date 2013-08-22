class AddConfigToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :config, :text
  end
end
