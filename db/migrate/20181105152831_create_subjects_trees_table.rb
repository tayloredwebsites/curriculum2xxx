class CreateSubjectsTreesTable < ActiveRecord::Migration[5.1]
  def up
    create_join_table :subjects, :trees do |t|
      t.index [:subject_id, :tree_id]
      t.index [:tree_id, :subject_id]
    end
  end

  def down
    drop_join_table :subjects, :trees
  end
end
