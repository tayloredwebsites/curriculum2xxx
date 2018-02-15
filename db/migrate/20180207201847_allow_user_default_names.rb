class AllowUserDefaultNames < ActiveRecord::Migration[5.1]
  # allow devise to let users signup/register
  def up
    change_column_default :users, :given_name, ''
    change_column_null :users, :given_name, true
    change_column_default :users, :family_name, ''
    change_column_null :users, :family_name, true
  end
  def down
    change_column_default :users, :given_name, nil
    change_column_null :users, :given_name, false
    change_column_default :users, :family_name, nil
    change_column_null :users, :family_name, false
  end
end
