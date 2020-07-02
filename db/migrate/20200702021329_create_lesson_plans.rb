class CreateLessonPlans < ActiveRecord::Migration[5.1]
  def change
    create_table :lesson_plans do |t|
      t.belongs_to :tree, :null => false, :index => true
      t.string :base_key
      t.integer :sequence
      t.boolean :is_exemplar
      t.references :exemplar_authorizor, foreign_key: {to_table: :users}, :index => true
      t.string :gd_owner_email
      t.boolean :submit_for_review
      t.boolean :is_draft
      t.boolean :in_portfolio
      t.timestamps
    end

    create_table :user_lesson_plans do |t|
      t.belongs_to :lesson_plan, :null => false, :index => true
      t.belongs_to :user, :null => false, :index => true
      t.timestamps
    end

   create_table :activities do |t|
      t.belongs_to :lesson_plan, :null => false, index: {name: 'activity_lp'}
      t.string :base_key
      t.integer :sequence
      t.integer :time_min
      t.string :student_org
      t.string :teach_strat
      t.timestamps
    end

    create_table :activity_dimensions do |t|
      t.belongs_to :activity, :null => false, :index => true
      t.belongs_to :dimension, :null => false, :index => true
      t.string :dim_code
      t.timestamps
    end

    create_table :lookup_tables_options do |t|
      t.string :table_name
      t.string :lookup_code
      t.string :lookup_translation_key
      t.timestamps
    end

  end
end
