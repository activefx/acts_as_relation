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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 12) do

  create_table "pencils", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pens", force: true do |t|
    t.integer  "as_pen_id"
    t.string   "as_pen_type"
    t.string   "color"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", force: true do |t|
    t.integer  "as_product_id"
    t.string   "as_product_type"
    t.integer  "organization_id"
    t.string   "name"
    t.float    "price"
    t.integer  "store_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stores", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "generic_models", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "organizations", force: true do |t|
    t.string "name"
    t.integer "sales"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "functions", force: true do |t|
    t.integer "as_organization_id"
    t.string "category"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "entities", force: true do |t|
    t.integer "as_organization_id"
    t.string "structure"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
end
