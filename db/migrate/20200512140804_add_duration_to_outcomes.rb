class AddDurationToOutcomes < ActiveRecord::Migration[5.1]
  def up
    add_column :outcomes, :duration_weeks, :integer, default: 0, null: false
    add_column :outcomes, :hours_per_week, :integer, default: 0, null: false
  end

  def down
  	remove_column :outcomes, :duration_weeks
    remove_column :outcomes, :hours_per_week
  end
end
