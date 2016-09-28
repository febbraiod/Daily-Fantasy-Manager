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

ActiveRecord::Schema.define(version: 20160928162406) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "opponents", force: :cascade do |t|
    t.string   "team"
    t.integer  "qb"
    t.integer  "wr"
    t.integer  "rb"
    t.integer  "te"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "players", force: :cascade do |t|
    t.string  "name"
    t.integer "salary"
    t.float   "projected_points", default: [], array: true
    t.float   "ownership"
    t.float   "averageppg"
    t.string  "team"
    t.string  "opponent"
    t.string  "injury_status"
    t.string  "position"
    t.integer "slate"
    t.float   "custom_proj"
    t.float   "dropoff"
    t.float   "cap"
    t.float   "dropoff_5"
    t.float   "cap_5"
  end

end
