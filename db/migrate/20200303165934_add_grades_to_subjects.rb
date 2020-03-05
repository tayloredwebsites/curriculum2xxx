# Gets updated to match the existing data for the subject.
class AddGradesToSubjects < ActiveRecord::Migration[5.1]
  def change
    add_column :subjects, :min_grade, :integer, default: 999, null: false
    add_column :subjects, :max_grade, :integer, default: 999, null: false
  end
end
