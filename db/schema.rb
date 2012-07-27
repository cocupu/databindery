# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120727173145) do

  create_table "change_sets", :force => true do |t|
    t.hstore   "data"
    t.integer  "pool_id"
    t.integer  "identity_id"
    t.integer  "parent_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "change_sets", ["data"], :name => "change_sets_gist_data"

  create_table "chattels", :force => true do |t|
    t.string   "attachment_content_type"
    t.string   "attachment_file_name"
    t.string   "attachment_extension"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  create_table "exhibits", :force => true do |t|
    t.string   "title"
    t.text     "facets"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "identities", :force => true do |t|
    t.string   "name"
    t.integer  "login_credential_id"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "job_log_items", :force => true do |t|
    t.string   "status"
    t.string   "name"
    t.text     "message"
    t.text     "data"
    t.integer  "parent_id"
    t.string   "type"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "login_credentials", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "login_credentials", ["email"], :name => "index_login_credentials_on_email", :unique => true
  add_index "login_credentials", ["reset_password_token"], :name => "index_login_credentials_on_reset_password_token", :unique => true

  create_table "mapping_templates", :force => true do |t|
    t.integer  "row_start"
    t.text     "models"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "file_type"
  end

  create_table "models", :force => true do |t|
    t.string   "name"
    t.hstore   "fields"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "nodes", :force => true do |t|
    t.hstore   "data"
    t.string   "persistent_id"
    t.string   "parent_id"
    t.integer  "pool_id"
    t.integer  "identity_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "model_id"
  end

  add_index "nodes", ["data"], :name => "nodes_gist_data"
  add_index "nodes", ["model_id"], :name => "index_nodes_on_model_id"

  create_table "pools", :force => true do |t|
    t.string   "name"
    t.integer  "owner_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "head_id"
  end

  create_table "spreadsheet_rows", :force => true do |t|
    t.integer  "row_number"
    t.integer  "worksheet_id"
    t.text     "values"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "worksheets", :force => true do |t|
    t.string   "name"
    t.integer  "spreadsheet_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_foreign_key "change_sets", "change_sets", :name => "change_sets_parent_id_fk", :column => "parent_id"
  add_foreign_key "change_sets", "identities", :name => "change_sets_identity_id_fk"
  add_foreign_key "change_sets", "pools", :name => "change_sets_pool_id_fk"

  add_foreign_key "identities", "login_credentials", :name => "identities_login_credential_id_fk"

  add_foreign_key "nodes", "identities", :name => "nodes_identity_id_fk"
  add_foreign_key "nodes", "pools", :name => "nodes_pool_id_fk"

  add_foreign_key "pools", "change_sets", :name => "pools_head_id_fk", :column => "head_id"
  add_foreign_key "pools", "identities", :name => "pools_owner_id_fk", :column => "owner_id"

end
