# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20101124090545) do

  create_table "accounts", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "account_type"
    t.string   "industry_type"
    t.string   "website"
  end

  create_table "bills", :force => true do |t|
    t.string   "cod"
    t.boolean  "charged"
    t.date     "charged_date"
    t.integer  "offer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", :force => true do |t|
    t.string   "title",            :limit => 50, :default => ""
    t.text     "comment"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"
  add_index "comments", ["commentable_type"], :name => "index_comments_on_commentable_type"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "contacts", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sur_name"
    t.string   "lead_source"
    t.string   "title"
    t.string   "department"
    t.integer  "account_id"
    t.integer  "seat_id"
    t.text     "contact_means"
  end

  add_index "contacts", ["account_id"], :name => "index_contacts_on_account_id"
  add_index "contacts", ["seat_id"], :name => "index_contacts_on_seat_id"

  create_table "offer_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "offers", :force => true do |t|
    t.string   "commercial_id"
    t.date     "creation_day"
    t.string   "state"
    t.boolean  "full_billed",               :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
    t.string   "order_cod"
    t.integer  "win_probability"
    t.date     "estimated_date_resolution"
    t.integer  "intermediary_id"
    t.integer  "actual_version_index"
    t.integer  "responsable_id"
    t.integer  "offer_type_id"
    t.string   "approved_doc_file_name"
    t.integer  "approved_doc_content_type"
    t.integer  "approved_doc_file_size"
    t.datetime "approved_doc_updated_at"
  end

  add_index "offers", ["account_id"], :name => "index_offers_on_account_id"

  create_table "resources", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "url"
    t.integer  "user_id"
  end

  create_table "seats", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "street"
    t.string   "city"
    t.string   "state"
    t.string   "postalcode"
    t.string   "country"
    t.integer  "account_id"
    t.string   "name"
    t.text     "contact_means"
  end

  add_index "seats", ["account_id"], :name => "index_seats_on_account_id"

  create_table "users", :force => true do |t|
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",                                   :default => "active"
    t.datetime "key_timestamp"
    t.string   "role",                                    :default => "Guest"
  end

  add_index "users", ["state"], :name => "index_users_on_state"

  create_table "versions", :force => true do |t|
    t.integer  "cod"
    t.integer  "licences_amount"
    t.integer  "recurrent_services_amount"
    t.integer  "no_recurrent_services_amount"
    t.integer  "offer_id"
    t.string   "description"
    t.string   "doc_file_name"
    t.string   "doc_content_type"
    t.integer  "doc_file_size"
    t.datetime "doc_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
