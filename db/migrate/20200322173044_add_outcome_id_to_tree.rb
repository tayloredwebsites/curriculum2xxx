class AddOutcomeIdToTree < ActiveRecord::Migration[5.1]
  def up
    create_table :outcomes do |t|
      # Outcome model methods to obtain translations from the base_key:
      # get_evidence_of_learning_key
      # get_connections_key
      # get_explain_key
      t.string :base_key
      t.timestamps
    end
    add_column :trees, :outcome_id, :integer, default: nil
    add_index :trees, :outcome_id, unique: true
    add_column :tree_types, :ess_q_dim_type, default: '', null: false
    add_column :tree_types, :tree_code_format, default: '', null: false
    add_column :tree_types, :detail_headers, default: '', null: false
    add_column :tree_types, :grid_headers, default: '', null: false
   end

  def down
    drop_table :outcomes
    remove_column :trees, :outcome_id
    remove_column :tree_types, :ess_q_dim_type
    remove_column :tree_types, :tree_code_format
  end
end
