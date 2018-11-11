class ErrorsInTwoPhases < ActiveRecord::Migration[5.1]
  def change
    add_column :uploads, :statusPhase2, :text
  end
end
