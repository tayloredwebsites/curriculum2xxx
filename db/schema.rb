# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20200630175056) do

  create_table "dimension_trees", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "dimension_id", null: false
    t.bigint "tree_id", null: false
    t.string "dim_explanation_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true
    t.index ["dimension_id"], name: "index_dimension_trees_on_dimension_id"
    t.index ["tree_id"], name: "index_dimension_trees_on_tree_id"
  end

  create_table "dimensions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "subject_id"
    t.string "dim_type"
    t.string "dim_code"
    t.string "dim_name_key"
    t.string "dim_desc_key"
    t.integer "dim_order", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "min_grade", default: 999, null: false
    t.integer "max_grade", default: 999, null: false
    t.string "subject_code", default: "", null: false
    t.boolean "active", default: true, null: false
    t.index ["dim_code"], name: "index_dimensions_on_dim_code"
    t.index ["dim_type", "dim_code"], name: "index_dimensions_on_dim_type_and_dim_code"
    t.index ["subject_id"], name: "index_dimensions_on_subject_id"
  end

  create_table "grade_bands", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "tree_type_id", null: false
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sort_order", default: 0
    t.boolean "active", default: true
    t.integer "min_grade", default: 999, null: false
    t.integer "max_grade", default: 999, null: false
    t.index ["tree_type_id"], name: "index_grade_bands_on_tree_type_id"
  end

  create_table "locales", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "code"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "outcomes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "base_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "duration_weeks", default: 0, null: false
    t.integer "hours_per_week", default: 0, null: false
  end

  create_table "resource_joins", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.bigint "resource_id", null: false
    t.string "resourceable_type"
    t.bigint "resourceable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["resource_id"], name: "index_resource_joins_on_resource_id"
    t.index ["resourceable_type", "resourceable_id"], name: "resourceable"
  end

  create_table "resources", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "base_key", default: "", null: false
    t.string "resource_code", default: "", null: false
  end

  create_table "sector_trees", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "sector_id", null: false
    t.bigint "tree_id", null: false
    t.string "explanation_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true
    t.index ["sector_id"], name: "index_sector_trees_on_sector_id"
    t.index ["tree_id"], name: "index_sector_trees_on_tree_id"
  end

  create_table "sectors", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "code"
    t.string "name_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "base_key"
    t.boolean "active", default: true
    t.string "sector_set_code", default: "", null: false
    t.string "key_phrase", default: "", null: false
    t.index ["code"], name: "index_sectors_on_code"
  end

  create_table "subjects", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "tree_type_id", null: false
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "base_key"
    t.boolean "active", default: true
    t.integer "min_grade", default: 999, null: false
    t.integer "max_grade", default: 999, null: false
    t.index ["tree_type_id"], name: "index_subjects_on_tree_type_id"
  end

  create_table "translations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "locale"
    t.string "key"
    t.text "value"
    t.text "interpolations"
    t.boolean "is_proc", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_translations_on_key"
    t.index ["value"], name: "index_translations_on_value", length: { value: 255 }
  end

  create_table "tree_trees", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "tree_referencer_id", null: false
    t.bigint "tree_referencee_id", null: false
    t.string "relationship"
    t.string "explanation_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true
    t.index ["tree_referencee_id"], name: "index_tree_trees_on_tree_referencee_id"
    t.index ["tree_referencer_id"], name: "index_tree_trees_on_tree_referencer_id"
  end

  create_table "tree_types", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true
    t.string "hierarchy_codes", default: "", null: false
    t.string "valid_locales", default: "en", null: false
    t.string "sector_set_code", default: "", null: false
    t.string "sector_set_name_key", default: "", null: false
    t.string "curriculum_title_key", default: "", null: false
    t.integer "outcome_depth", default: 0, null: false
    t.integer "version_id", default: 0, null: false
    t.boolean "working_status", default: true
    t.string "tree_code_format", default: "", null: false
    t.string "detail_headers", default: "", null: false
    t.string "grid_headers", default: "", null: false
    t.string "dim_codes", default: "bigidea,miscon", null: false
    t.string "dim_display", default: "", null: false
    t.string "user_form_config", default: "", null: false
    t.index ["code", "version_id"], name: "index_tree_types_on_code_and_version_id", unique: true
  end

  create_table "trees", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "tree_type_id", null: false
    t.integer "version_id", null: false
    t.integer "subject_id", null: false
    t.integer "grade_band_id", null: false
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name_key"
    t.string "base_key"
    t.string "matching_codes", default: "[]"
    t.integer "depth", default: 0
    t.integer "sort_order", default: 0
    t.integer "sequence_order", default: 0
    t.boolean "active", default: true
    t.integer "old_tree_id"
    t.integer "outcome_id"
    t.index ["grade_band_id"], name: "index_trees_on_grade_band_id"
    t.index ["name_key"], name: "index_trees_on_name_key"
    t.index ["outcome_id"], name: "index_trees_on_outcome_id", unique: true
    t.index ["subject_id"], name: "index_trees_on_subject_id"
    t.index ["tree_type_id", "version_id", "subject_id", "grade_band_id", "code"], name: "index_trees_on_keys"
    t.index ["tree_type_id"], name: "index_trees_on_tree_type_id"
    t.index ["version_id"], name: "index_trees_on_version_id"
  end

  create_table "uploads", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "subject_id", null: false
    t.integer "grade_band_id"
    t.integer "locale_id", null: false
    t.integer "status"
    t.text "status_detail"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "filename"
    t.text "statusPhase2"
    t.string "tree_type_code", default: "", null: false
    t.index ["grade_band_id"], name: "index_uploads_on_grade_band_id"
    t.index ["locale_id"], name: "index_uploads_on_locale_id"
    t.index ["subject_id", "grade_band_id", "locale_id"], name: "index_uploads_on_keys"
    t.index ["subject_id"], name: "index_uploads_on_subject_id"
  end

  create_table "user_resources", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.bigint "resource_id", null: false
    t.bigint "user_id", null: false
    t.string "user_resourceable_type"
    t.bigint "user_resourceable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["resource_id"], name: "index_user_resources_on_resource_id"
    t.index ["user_id"], name: "index_user_resources_on_user_id"
    t.index ["user_resourceable_type", "user_resourceable_id"], name: "user_resourceable"
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "given_name", default: ""
    t.string "family_name", default: ""
    t.string "roles", default: "", null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "locked_at"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "govt_level"
    t.string "govt_level_name"
    t.string "municipality"
    t.string "institute_type"
    t.string "institute_name_loc"
    t.string "position_type"
    t.string "subject1"
    t.string "subject2"
    t.string "gender"
    t.string "education_level"
    t.string "work_phone"
    t.string "work_address"
    t.boolean "terms_accepted"
    t.integer "last_tree_type_id"
    t.string "last_selected_subject_ids", default: "", null: false
    t.integer "last_version_id"
    t.string "admin_subjects", default: "", null: false
    t.boolean "active", default: true, null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "versions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true
  end

end
