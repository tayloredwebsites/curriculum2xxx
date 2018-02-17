class AddUserFields < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :govt_level, :string
    add_column :users, :govt_level_name, :string
    add_column :users, :municipality, :string
    add_column :users, :institute_type, :string
    add_column :users, :institute_name_loc, :string
    add_column :users, :position_type, :string
    add_column :users, :subject1, :string
    add_column :users, :subject2, :string
    add_column :users, :gender, :string
    add_column :users, :education_level, :string
    add_column :users, :work_phone, :string
    add_column :users, :work_address, :string
    add_column :users, :terms_accepted, :boolean
  end
end
