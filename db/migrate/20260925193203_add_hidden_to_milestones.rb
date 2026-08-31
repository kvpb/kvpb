class AddHiddenToMilestones < ActiveRecord::Migration[ 8.1 ]
  def change
    add_column :milestones, :hidden, :boolean, null: false, default: false
  end
end
