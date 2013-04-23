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

ActiveRecord::Schema.define(:version => 20130418012853) do

  create_table "annotation_versions", :force => true do |t|
    t.integer  "annotation_id"
    t.integer  "version"
    t.integer  "collage_id"
    t.string   "annotation",            :limit => 10240
    t.string   "annotation_start"
    t.string   "annotation_end"
    t.integer  "word_count"
    t.string   "annotated_content",     :limit => 1048576
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ancestry"
    t.boolean  "public",                                   :default => true
    t.boolean  "active",                                   :default => true
    t.integer  "annotation_word_count"
    t.integer  "collage_version"
  end

  add_index "annotation_versions", ["annotation_id"], :name => "index_annotation_versions_on_annotation_id"

  create_table "annotations", :force => true do |t|
    t.integer  "collage_id"
    t.string   "annotation",            :limit => 10240
    t.string   "annotation_start"
    t.string   "annotation_end"
    t.integer  "word_count"
    t.string   "annotated_content",     :limit => 1048576
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ancestry"
    t.boolean  "public",                                   :default => true
    t.boolean  "active",                                   :default => true
    t.integer  "annotation_word_count"
    t.integer  "collage_version"
    t.integer  "version"
    t.integer  "pushed_from_id"
  end

  add_index "annotations", ["active"], :name => "index_annotations_on_active"
  add_index "annotations", ["ancestry"], :name => "index_annotations_on_ancestry"
  add_index "annotations", ["annotation_end"], :name => "index_annotations_on_annotation_end"
  add_index "annotations", ["annotation_start"], :name => "index_annotations_on_annotation_start"
  add_index "annotations", ["public"], :name => "index_annotations_on_public"

  create_table "brain_busters", :force => true do |t|
    t.string "question"
    t.string "answer"
  end

  create_table "case_citation_versions", :force => true do |t|
    t.integer  "case_citation_id"
    t.integer  "version"
    t.integer  "case_id"
    t.string   "volume",           :limit => 200
    t.string   "reporter",         :limit => 200
    t.string   "page",             :limit => 200
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "case_version"
  end

  add_index "case_citation_versions", ["case_citation_id"], :name => "index_case_citation_versions_on_case_citation_id"

  create_table "case_citations", :force => true do |t|
    t.integer  "case_id"
    t.string   "volume",       :limit => 200, :null => false
    t.string   "reporter",     :limit => 200, :null => false
    t.string   "page",         :limit => 200, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "case_version"
    t.integer  "version"
  end

  add_index "case_citations", ["case_id"], :name => "index_case_citations_on_case_id"
  add_index "case_citations", ["page"], :name => "index_case_citations_on_page"
  add_index "case_citations", ["reporter"], :name => "index_case_citations_on_reporter"
  add_index "case_citations", ["volume"], :name => "index_case_citations_on_volume"

  create_table "case_docket_number_versions", :force => true do |t|
    t.integer  "case_docket_number_id"
    t.integer  "version"
    t.integer  "case_id"
    t.string   "docket_number",         :limit => 200
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "case_version"
  end

  add_index "case_docket_number_versions", ["case_docket_number_id"], :name => "index_case_docket_number_versions_on_case_docket_number_id"

  create_table "case_docket_numbers", :force => true do |t|
    t.integer  "case_id"
    t.string   "docket_number", :limit => 200, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "case_version"
    t.integer  "version"
  end

  add_index "case_docket_numbers", ["case_id"], :name => "index_case_docket_numbers_on_case_id"
  add_index "case_docket_numbers", ["docket_number"], :name => "index_case_docket_numbers_on_docket_number"

  create_table "case_jurisdiction_versions", :force => true do |t|
    t.integer  "case_jurisdiction_id"
    t.integer  "version"
    t.string   "abbreviation",         :limit => 150
    t.string   "name",                 :limit => 500
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "case_jurisdiction_versions", ["case_jurisdiction_id"], :name => "index_case_jurisdiction_versions_on_case_jurisdiction_id"

  create_table "case_jurisdictions", :force => true do |t|
    t.string   "abbreviation", :limit => 150
    t.string   "name",         :limit => 500
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "version"
  end

  add_index "case_jurisdictions", ["abbreviation"], :name => "index_case_jurisdictions_on_abbreviation"
  add_index "case_jurisdictions", ["name"], :name => "index_case_jurisdictions_on_name"

  create_table "case_request_versions", :force => true do |t|
    t.integer  "case_request_id"
    t.integer  "version"
    t.string   "full_name",                 :limit => 500
    t.date     "decision_date"
    t.string   "author",                    :limit => 150
    t.integer  "case_jurisdiction_id"
    t.string   "docket_number",             :limit => 150
    t.string   "volume",                    :limit => 150
    t.string   "reporter",                  :limit => 150
    t.string   "page",                      :limit => 150
    t.string   "bluebook_citation",         :limit => 150
    t.string   "status",                    :limit => 150, :default => "new"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "case_jurisdiction_version"
  end

  add_index "case_request_versions", ["case_request_id"], :name => "index_case_request_versions_on_case_request_id"

  create_table "case_requests", :force => true do |t|
    t.string   "full_name",                 :limit => 500,                    :null => false
    t.date     "decision_date",                                               :null => false
    t.string   "author",                    :limit => 150,                    :null => false
    t.integer  "case_jurisdiction_id"
    t.string   "docket_number",             :limit => 150,                    :null => false
    t.string   "volume",                    :limit => 150,                    :null => false
    t.string   "reporter",                  :limit => 150,                    :null => false
    t.string   "page",                      :limit => 150,                    :null => false
    t.string   "bluebook_citation",         :limit => 150,                    :null => false
    t.string   "status",                    :limit => 150, :default => "new", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "case_jurisdiction_version"
    t.integer  "version"
  end

  create_table "case_versions", :force => true do |t|
    t.integer  "case_id"
    t.integer  "version"
    t.boolean  "current_opinion",                              :default => true
    t.string   "short_name",                :limit => 150
    t.string   "full_name",                 :limit => 500
    t.date     "decision_date"
    t.string   "author",                    :limit => 150
    t.integer  "case_jurisdiction_id"
    t.string   "party_header",              :limit => 10240
    t.string   "lawyer_header",             :limit => 2048
    t.string   "header_html",               :limit => 15360
    t.string   "content",                   :limit => 5242880
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "public",                                       :default => true
    t.boolean  "active",                                       :default => false
    t.integer  "case_request_id"
    t.integer  "case_jurisdiction_version"
    t.integer  "case_request_version"
  end

  add_index "case_versions", ["case_id"], :name => "index_case_versions_on_case_id"

  create_table "cases", :force => true do |t|
    t.boolean  "current_opinion",                              :default => true
    t.string   "short_name",                :limit => 150,                        :null => false
    t.string   "full_name",                 :limit => 500
    t.date     "decision_date"
    t.string   "author",                    :limit => 150
    t.integer  "case_jurisdiction_id"
    t.string   "party_header",              :limit => 10240
    t.string   "lawyer_header",             :limit => 2048
    t.string   "header_html",               :limit => 15360
    t.string   "content",                   :limit => 5242880,                    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "public",                                       :default => true
    t.boolean  "active",                                       :default => false
    t.integer  "case_request_id"
    t.integer  "case_jurisdiction_version"
    t.integer  "case_request_version"
    t.integer  "version"
    t.integer  "pushed_from_id"
  end

  add_index "cases", ["active"], :name => "index_cases_on_active"
  add_index "cases", ["author"], :name => "index_cases_on_author"
  add_index "cases", ["case_jurisdiction_id"], :name => "index_cases_on_case_jurisdiction_id"
  add_index "cases", ["created_at"], :name => "index_cases_on_created_at"
  add_index "cases", ["current_opinion"], :name => "index_cases_on_current_opinion"
  add_index "cases", ["decision_date"], :name => "index_cases_on_decision_date"
  add_index "cases", ["full_name"], :name => "index_cases_on_full_name"
  add_index "cases", ["public"], :name => "index_cases_on_public"
  add_index "cases", ["short_name"], :name => "index_cases_on_short_name"
  add_index "cases", ["updated_at"], :name => "index_cases_on_updated_at"

  create_table "collage_link_versions", :force => true do |t|
    t.integer  "collage_link_id"
    t.integer  "version"
    t.integer  "host_collage_id"
    t.integer  "linked_collage_id"
    t.string   "link_text_start"
    t.string   "link_text_end"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "host_collage_version"
    t.integer  "linked_collage_version"
  end

  add_index "collage_link_versions", ["collage_link_id"], :name => "index_collage_link_versions_on_collage_link_id"

  create_table "collage_links", :force => true do |t|
    t.integer  "host_collage_id",        :null => false
    t.integer  "linked_collage_id",      :null => false
    t.string   "link_text_start",        :null => false
    t.string   "link_text_end",          :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "host_collage_version"
    t.integer  "linked_collage_version"
    t.integer  "version"
  end

  create_table "collage_versions", :force => true do |t|
    t.integer  "collage_id"
    t.integer  "version"
    t.string   "annotatable_type"
    t.integer  "annotatable_id"
    t.string   "name",                :limit => 250
    t.string   "description",         :limit => 5120
    t.string   "content",             :limit => 5242880
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "word_count"
    t.string   "indexable_content",   :limit => 5242880
    t.string   "ancestry"
    t.boolean  "public",                                 :default => true
    t.boolean  "active",                                 :default => true
    t.string   "readable_state",      :limit => 5242880
    t.integer  "words_shown"
    t.integer  "annotatable_version"
  end

  add_index "collage_versions", ["collage_id"], :name => "index_collage_versions_on_collage_id"

  create_table "collages", :force => true do |t|
    t.string   "annotatable_type"
    t.integer  "annotatable_id"
    t.string   "name",                :limit => 250,                       :null => false
    t.string   "description",         :limit => 5120
    t.string   "content",             :limit => 5242880,                   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "word_count"
    t.string   "indexable_content",   :limit => 5242880
    t.string   "ancestry"
    t.boolean  "public",                                 :default => true
    t.boolean  "active",                                 :default => true
    t.string   "readable_state",      :limit => 5242880
    t.integer  "words_shown"
    t.integer  "annotatable_version"
    t.integer  "version"
    t.integer  "pushed_from_id"
  end

  add_index "collages", ["active"], :name => "index_collages_on_active"
  add_index "collages", ["ancestry"], :name => "index_collages_on_ancestry"
  add_index "collages", ["annotatable_id"], :name => "index_collages_on_annotatable_id"
  add_index "collages", ["annotatable_type"], :name => "index_collages_on_annotatable_type"
  add_index "collages", ["created_at"], :name => "index_collages_on_created_at"
  add_index "collages", ["name"], :name => "index_collages_on_name"
  add_index "collages", ["public"], :name => "index_collages_on_public"
  add_index "collages", ["updated_at"], :name => "index_collages_on_updated_at"
  add_index "collages", ["word_count"], :name => "index_collages_on_word_count"

  create_table "collages_user_collections", :id => false, :force => true do |t|
    t.integer "collage_id"
    t.integer "user_collection_id"
    t.integer "collage_version"
    t.integer "user_collection_version"
  end

  create_table "collages_user_collections_versions", :id => false, :force => true do |t|
    t.integer "collage_id"
    t.integer "user_collection_id"
    t.integer "collage_version"
    t.integer "user_collection_version"
  end

  create_table "color_mapping_versions", :force => true do |t|
    t.integer  "color_mapping_id"
    t.integer  "version"
    t.integer  "collage_id"
    t.integer  "tag_id"
    t.string   "hex"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tag_version"
    t.integer  "colllage_version"
  end

  add_index "color_mapping_versions", ["color_mapping_id"], :name => "index_color_mapping_versions_on_color_mapping_id"

  create_table "color_mappings", :force => true do |t|
    t.integer  "collage_id"
    t.integer  "tag_id"
    t.string   "hex"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tag_version"
    t.integer  "colllage_version"
    t.integer  "version"
  end

  create_table "defect_versions", :force => true do |t|
    t.integer  "defect_id"
    t.integer  "version"
    t.text     "description"
    t.integer  "reportable_id"
    t.string   "reportable_type"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "reportable_version"
    t.integer  "reporter_version"
  end

  add_index "defect_versions", ["defect_id"], :name => "index_defect_versions_on_defect_id"

  create_table "defects", :force => true do |t|
    t.text     "description",        :null => false
    t.integer  "reportable_id",      :null => false
    t.string   "reportable_type",    :null => false
    t.integer  "user_id",            :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "reportable_version"
    t.integer  "reporter_version"
    t.integer  "version"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "influences", :force => true do |t|
    t.integer  "resource_id"
    t.string   "resource_type"
    t.integer  "parent_id"
    t.integer  "children_count"
    t.integer  "ancestors_count"
    t.integer  "descendants_count"
    t.boolean  "hidden"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "influences", ["ancestors_count"], :name => "index_influences_on_ancestors_count"
  add_index "influences", ["children_count"], :name => "index_influences_on_children_count"
  add_index "influences", ["descendants_count"], :name => "index_influences_on_descendants_count"
  add_index "influences", ["parent_id"], :name => "index_influences_on_parent_id"
  add_index "influences", ["resource_id"], :name => "index_influences_on_resource_id"
  add_index "influences", ["resource_type"], :name => "index_influences_on_resource_type"

  create_table "item_annotations", :force => true do |t|
    t.string   "title"
    t.string   "name",               :limit => 1024
    t.string   "url",                :limit => 1024
    t.text     "description"
    t.boolean  "active",                             :default => true
    t.boolean  "public",                             :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "actual_object_type"
    t.integer  "actual_object_id"
    t.integer  "pushed_from_id"
  end

  add_index "item_annotations", ["active"], :name => "index_item_annotations_on_active"
  add_index "item_annotations", ["actual_object_id"], :name => "index_item_annotations_on_actual_object_id"
  add_index "item_annotations", ["actual_object_type"], :name => "index_item_annotations_on_actual_object_type"
  add_index "item_annotations", ["public"], :name => "index_item_annotations_on_public"
  add_index "item_annotations", ["url"], :name => "index_item_annotations_on_url"

  create_table "item_cases", :force => true do |t|
    t.string   "title"
    t.string   "name",               :limit => 1024
    t.string   "url",                :limit => 1024
    t.text     "description"
    t.boolean  "active",                             :default => true
    t.boolean  "public",                             :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "actual_object_type"
    t.integer  "actual_object_id"
    t.integer  "pushed_from_id"
  end

  add_index "item_cases", ["active"], :name => "index_item_cases_on_active"
  add_index "item_cases", ["actual_object_id"], :name => "index_item_cases_on_actual_object_id"
  add_index "item_cases", ["actual_object_type"], :name => "index_item_cases_on_actual_object_type"
  add_index "item_cases", ["public"], :name => "index_item_cases_on_public"
  add_index "item_cases", ["url"], :name => "index_item_cases_on_url"

  create_table "item_collages", :force => true do |t|
    t.string   "title"
    t.string   "name",               :limit => 1024
    t.string   "url",                :limit => 1024
    t.text     "description"
    t.boolean  "active",                             :default => true
    t.boolean  "public",                             :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "actual_object_type"
    t.integer  "actual_object_id"
    t.integer  "pushed_from_id"
  end

  add_index "item_collages", ["active"], :name => "index_item_collages_on_active"
  add_index "item_collages", ["actual_object_id"], :name => "index_item_collages_on_actual_object_id"
  add_index "item_collages", ["actual_object_type"], :name => "index_item_collages_on_actual_object_type"
  add_index "item_collages", ["public"], :name => "index_item_collages_on_public"
  add_index "item_collages", ["url"], :name => "index_item_collages_on_url"

  create_table "item_defaults", :force => true do |t|
    t.string   "title"
    t.string   "name",           :limit => 1024
    t.string   "url",            :limit => 1024
    t.text     "description"
    t.boolean  "active",                         :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "public",                         :default => true
    t.integer  "pushed_from_id"
  end

  add_index "item_defaults", ["active"], :name => "index_item_defaults_on_active"
  add_index "item_defaults", ["url"], :name => "index_item_defaults_on_url"

  create_table "item_images", :force => true do |t|
    t.string   "title"
    t.string   "name",               :limit => 1024
    t.string   "url",                :limit => 1024
    t.text     "description"
    t.boolean  "active",                             :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "public",                             :default => true
    t.string   "actual_object_type"
    t.integer  "actual_object_id"
  end

  add_index "item_images", ["active"], :name => "index_item_images_on_active"
  add_index "item_images", ["actual_object_id"], :name => "index_item_images_on_actual_object_id"
  add_index "item_images", ["actual_object_type"], :name => "index_item_images_on_actual_object_type"
  add_index "item_images", ["url"], :name => "index_item_images_on_url"

  create_table "item_medias", :force => true do |t|
    t.string   "title"
    t.string   "name"
    t.string   "url",                :limit => 1024
    t.text     "description"
    t.string   "actual_object_type"
    t.integer  "actual_object_id"
    t.boolean  "active",                             :default => true
    t.boolean  "public",                             :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "pushed_from_id"
  end

  add_index "item_medias", ["active"], :name => "index_item_medias_on_active"
  add_index "item_medias", ["public"], :name => "index_item_medias_on_public"
  add_index "item_medias", ["url"], :name => "index_item_medias_on_url"

  create_table "item_playlists", :force => true do |t|
    t.string   "title"
    t.string   "name",               :limit => 1024
    t.string   "url",                :limit => 1024
    t.text     "description"
    t.boolean  "active",                             :default => true
    t.boolean  "public",                             :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "actual_object_type"
    t.integer  "actual_object_id"
    t.integer  "pushed_from_id"
  end

  add_index "item_playlists", ["active"], :name => "index_item_playlists_on_active"
  add_index "item_playlists", ["actual_object_id"], :name => "index_item_playlists_on_actual_object_id"
  add_index "item_playlists", ["actual_object_type"], :name => "index_item_playlists_on_actual_object_type"
  add_index "item_playlists", ["public"], :name => "index_item_playlists_on_public"
  add_index "item_playlists", ["url"], :name => "index_item_playlists_on_url"

  create_table "item_question_instances", :force => true do |t|
    t.string   "title"
    t.string   "name",               :limit => 1024
    t.string   "url",                :limit => 1024
    t.text     "description"
    t.boolean  "active",                             :default => true
    t.boolean  "public",                             :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "actual_object_type"
    t.integer  "actual_object_id"
    t.integer  "pushed_from_id"
  end

  add_index "item_question_instances", ["active"], :name => "index_item_question_instances_on_active"
  add_index "item_question_instances", ["actual_object_id"], :name => "index_item_question_instances_on_actual_object_id"
  add_index "item_question_instances", ["actual_object_type"], :name => "index_item_question_instances_on_actual_object_type"
  add_index "item_question_instances", ["public"], :name => "index_item_question_instances_on_public"
  add_index "item_question_instances", ["url"], :name => "index_item_question_instances_on_url"

  create_table "item_questions", :force => true do |t|
    t.string   "title"
    t.string   "name"
    t.string   "url"
    t.text     "description"
    t.boolean  "active"
    t.boolean  "public"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "actual_object_type"
    t.integer  "actual_object_id"
    t.integer  "pushed_from_id"
  end

  add_index "item_questions", ["active"], :name => "index_item_questions_on_active"
  add_index "item_questions", ["actual_object_id"], :name => "index_item_questions_on_actual_object_id"
  add_index "item_questions", ["actual_object_type"], :name => "index_item_questions_on_actual_object_type"
  add_index "item_questions", ["public"], :name => "index_item_questions_on_public"
  add_index "item_questions", ["url"], :name => "index_item_questions_on_url"

  create_table "item_rotisserie_discussions", :force => true do |t|
    t.string   "title"
    t.string   "name",               :limit => 1024
    t.string   "url",                :limit => 1024
    t.text     "description"
    t.boolean  "active",                             :default => true
    t.boolean  "public",                             :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "actual_object_type"
    t.integer  "actual_object_id"
    t.integer  "pushed_from_id"
  end

  add_index "item_rotisserie_discussions", ["active"], :name => "index_item_rotisserie_discussions_on_active"
  add_index "item_rotisserie_discussions", ["actual_object_id"], :name => "index_item_rotisserie_discussions_on_actual_object_id"
  add_index "item_rotisserie_discussions", ["actual_object_type"], :name => "index_item_rotisserie_discussions_on_actual_object_type"
  add_index "item_rotisserie_discussions", ["public"], :name => "index_item_rotisserie_discussions_on_public"
  add_index "item_rotisserie_discussions", ["url"], :name => "index_item_rotisserie_discussions_on_url"

  create_table "item_text_blocks", :force => true do |t|
    t.string   "title"
    t.string   "name",               :limit => 1024
    t.string   "url",                :limit => 1024
    t.text     "description"
    t.boolean  "active",                             :default => true
    t.boolean  "public",                             :default => true
    t.string   "actual_object_type"
    t.integer  "actual_object_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "pushed_from_id"
  end

  add_index "item_text_blocks", ["active"], :name => "index_item_text_blocks_on_active"
  add_index "item_text_blocks", ["actual_object_id"], :name => "index_item_text_blocks_on_actual_object_id"
  add_index "item_text_blocks", ["actual_object_type"], :name => "index_item_text_blocks_on_actual_object_type"
  add_index "item_text_blocks", ["public"], :name => "index_item_text_blocks_on_public"
  add_index "item_text_blocks", ["url"], :name => "index_item_text_blocks_on_url"

  create_table "item_texts", :force => true do |t|
    t.string   "title"
    t.string   "name",               :limit => 1024
    t.string   "url",                :limit => 1024
    t.text     "description"
    t.boolean  "active",                             :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "public",                             :default => true
    t.string   "actual_object_type"
    t.integer  "actual_object_id"
  end

  add_index "item_texts", ["active"], :name => "index_item_texts_on_active"
  add_index "item_texts", ["actual_object_id"], :name => "index_item_texts_on_actual_object_id"
  add_index "item_texts", ["actual_object_type"], :name => "index_item_texts_on_actual_object_type"
  add_index "item_texts", ["url"], :name => "index_item_texts_on_url"

  create_table "item_youtubes", :force => true do |t|
    t.string   "title"
    t.string   "name",        :limit => 1024
    t.string   "url",         :limit => 1024
    t.text     "description"
    t.boolean  "active",                      :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "public",                      :default => true
  end

  add_index "item_youtubes", ["active"], :name => "index_item_youtubes_on_active"
  add_index "item_youtubes", ["url"], :name => "index_item_youtubes_on_url"

  create_table "journal_article_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "journal_article_types_journal_articles", :id => false, :force => true do |t|
    t.integer "journal_article_id"
    t.integer "journal_article_type_id"
  end

  create_table "journal_articles", :force => true do |t|
    t.string   "name",                                                            :null => false
    t.string   "description",                :limit => 5242880,                   :null => false
    t.date     "publish_date",                                                    :null => false
    t.string   "subtitle"
    t.string   "author",                                                          :null => false
    t.string   "author_description",         :limit => 5242880
    t.string   "volume",                                                          :null => false
    t.string   "issue",                                                           :null => false
    t.string   "page",                                                            :null => false
    t.string   "bluebook_citation",                                               :null => false
    t.string   "article_series_title"
    t.string   "article_series_description", :limit => 5242880
    t.string   "pdf_url"
    t.string   "image"
    t.string   "attribution",                                                     :null => false
    t.string   "attribution_url"
    t.string   "video_embed",                :limit => 5242880
    t.boolean  "active",                                        :default => true
    t.boolean  "public",                                        :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "media_types", :force => true do |t|
    t.string   "label"
    t.string   "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "medias", :force => true do |t|
    t.string   "name"
    t.text     "content"
    t.integer  "media_type_id"
    t.boolean  "public",                            :default => true
    t.boolean  "active",                            :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "description",    :limit => 5242880
    t.integer  "pushed_from_id"
  end

  create_table "metadata", :force => true do |t|
    t.string   "contributor"
    t.string   "coverage"
    t.string   "creator"
    t.date     "date"
    t.string   "description",          :limit => 5242880
    t.string   "format"
    t.string   "identifier"
    t.string   "language",                                :default => "en"
    t.string   "publisher"
    t.string   "relation"
    t.string   "rights"
    t.string   "source"
    t.string   "subject"
    t.string   "title"
    t.string   "dc_type",                                 :default => "Text"
    t.string   "classifiable_type"
    t.integer  "classifiable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "classifiable_version"
    t.integer  "version"
  end

  add_index "metadata", ["classifiable_id"], :name => "index_metadata_on_classifiable_id"
  add_index "metadata", ["classifiable_type"], :name => "index_metadata_on_classifiable_type"

  create_table "metadatum_versions", :force => true do |t|
    t.integer  "metadatum_id"
    t.integer  "version"
    t.string   "contributor"
    t.string   "coverage"
    t.string   "creator"
    t.date     "date"
    t.string   "description",          :limit => 5242880
    t.string   "format"
    t.string   "identifier"
    t.string   "language",                                :default => "en"
    t.string   "publisher"
    t.string   "relation"
    t.string   "rights"
    t.string   "source"
    t.string   "subject"
    t.string   "title"
    t.string   "dc_type",                                 :default => "Text"
    t.string   "classifiable_type"
    t.integer  "classifiable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "classifiable_version"
  end

  add_index "metadatum_versions", ["metadatum_id"], :name => "index_metadatum_versions_on_metadatum_id"

  create_table "notification_invites", :force => true do |t|
    t.integer  "user_id"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.string   "email_address", :limit => 1024
    t.string   "tid",           :limit => 1024
    t.boolean  "sent",                          :default => false
    t.boolean  "accepted",                      :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notification_invites", ["email_address"], :name => "index_notification_invites_on_email_address"
  add_index "notification_invites", ["tid"], :name => "index_notification_invites_on_tid"
  add_index "notification_invites", ["user_id"], :name => "index_notification_invites_on_user_id"

  create_table "notification_trackers", :force => true do |t|
    t.integer  "rotisserie_discussion_id"
    t.integer  "rotisserie_post_id"
    t.integer  "user_id"
    t.string   "notify_description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notification_trackers", ["rotisserie_discussion_id"], :name => "index_notification_trackers_on_rotisserie_discussion_id"
  add_index "notification_trackers", ["rotisserie_post_id"], :name => "index_notification_trackers_on_rotisserie_post_id"
  add_index "notification_trackers", ["user_id"], :name => "index_notification_trackers_on_user_id"

  create_table "permission_assignments", :force => true do |t|
    t.integer  "user_collection_id"
    t.integer  "user_id"
    t.integer  "permission_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "permissions", :force => true do |t|
    t.string   "key"
    t.string   "label"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "permission_type"
  end

  create_table "playlist_items", :force => true do |t|
    t.integer  "playlist_id"
    t.integer  "resource_item_id"
    t.string   "resource_item_type"
    t.boolean  "active",                  :default => true
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ancestry"
    t.integer  "playlist_item_parent_id"
    t.boolean  "public",                  :default => true
    t.text     "notes"
    t.boolean  "public_notes",            :default => true, :null => false
    t.integer  "pushed_from_id"
  end

  add_index "playlist_items", ["active"], :name => "index_playlist_items_on_active"
  add_index "playlist_items", ["ancestry"], :name => "index_playlist_items_on_ancestry"
  add_index "playlist_items", ["playlist_item_parent_id"], :name => "index_playlist_items_on_playlist_item_parent_id"
  add_index "playlist_items", ["position"], :name => "index_playlist_items_on_position"
  add_index "playlist_items", ["public"], :name => "index_playlist_items_on_public"
  add_index "playlist_items", ["resource_item_id"], :name => "index_playlist_items_on_resource_item_id"
  add_index "playlist_items", ["resource_item_type"], :name => "index_playlist_items_on_resource_item_type"

  create_table "playlists", :force => true do |t|
    t.string   "title",                                            :null => false
    t.string   "name",           :limit => 1024
    t.text     "description"
    t.boolean  "active",                         :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "public",                         :default => true
    t.string   "ancestry"
    t.integer  "position"
    t.integer  "counter_start",                  :default => 1,    :null => false
    t.integer  "pushed_from_id"
  end

  add_index "playlists", ["active"], :name => "index_playlists_on_active"
  add_index "playlists", ["ancestry"], :name => "index_playlists_on_ancestry"
  add_index "playlists", ["position"], :name => "index_playlists_on_position"

  create_table "playlists_user_collections", :id => false, :force => true do |t|
    t.integer "playlist_id"
    t.integer "user_collection_id"
    t.integer "user_collection_version"
  end

  create_table "playlists_user_collections_versions", :id => false, :force => true do |t|
    t.integer "playlist_id"
    t.integer "user_collection_id"
    t.integer "user_collection_version"
  end

  create_table "question_instances", :force => true do |t|
    t.string   "name",                    :limit => 250,                    :null => false
    t.integer  "user_id"
    t.integer  "project_id"
    t.string   "password",                :limit => 128
    t.integer  "featured_question_count",                 :default => 2
    t.string   "description",             :limit => 2000
    t.integer  "parent_id"
    t.integer  "children_count"
    t.integer  "ancestors_count"
    t.integer  "descendants_count"
    t.integer  "position"
    t.boolean  "hidden"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "public",                                  :default => true
    t.boolean  "active",                                  :default => true
    t.integer  "pushed_from_id"
  end

  add_index "question_instances", ["active"], :name => "index_question_instances_on_active"
  add_index "question_instances", ["ancestors_count"], :name => "index_question_instances_on_ancestors_count"
  add_index "question_instances", ["children_count"], :name => "index_question_instances_on_children_count"
  add_index "question_instances", ["descendants_count"], :name => "index_question_instances_on_descendants_count"
  add_index "question_instances", ["hidden"], :name => "index_question_instances_on_hidden"
  add_index "question_instances", ["name"], :name => "index_question_instances_on_name", :unique => true
  add_index "question_instances", ["parent_id"], :name => "index_question_instances_on_parent_id"
  add_index "question_instances", ["position"], :name => "index_question_instances_on_position"
  add_index "question_instances", ["project_id", "position"], :name => "index_question_instances_on_project_id_and_position", :unique => true
  add_index "question_instances", ["project_id"], :name => "index_question_instances_on_project_id"
  add_index "question_instances", ["public"], :name => "index_question_instances_on_public"
  add_index "question_instances", ["user_id"], :name => "index_question_instances_on_user_id"

  create_table "questions", :force => true do |t|
    t.integer  "question_instance_id"
    t.integer  "user_id"
    t.string   "question",             :limit => 10000,                    :null => false
    t.boolean  "sticky",                                :default => false
    t.integer  "parent_id"
    t.integer  "children_count"
    t.integer  "ancestors_count"
    t.integer  "descendants_count"
    t.integer  "position"
    t.boolean  "hidden"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "public",                                :default => true
    t.boolean  "active",                                :default => true
    t.integer  "pushed_from_id"
  end

  add_index "questions", ["active"], :name => "index_questions_on_active"
  add_index "questions", ["created_at"], :name => "index_questions_on_created_at"
  add_index "questions", ["parent_id"], :name => "index_questions_on_parent_id"
  add_index "questions", ["position"], :name => "index_questions_on_position"
  add_index "questions", ["public"], :name => "index_questions_on_public"
  add_index "questions", ["question_instance_id"], :name => "index_questions_on_question_instance_id"
  add_index "questions", ["sticky"], :name => "index_questions_on_sticky"
  add_index "questions", ["updated_at"], :name => "index_questions_on_updated_at"
  add_index "questions", ["user_id"], :name => "index_questions_on_user_id"

  create_table "role_versions", :force => true do |t|
    t.integer  "role_id"
    t.integer  "version"
    t.string   "name",                 :limit => 40
    t.string   "authorizable_type",    :limit => 40
    t.integer  "authorizable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "authorizable_version"
  end

  add_index "role_versions", ["role_id"], :name => "index_role_versions_on_role_id"

  create_table "roles", :force => true do |t|
    t.string   "name",                 :limit => 40
    t.string   "authorizable_type",    :limit => 40
    t.integer  "authorizable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "authorizable_version"
    t.integer  "version"
  end

  add_index "roles", ["authorizable_id"], :name => "index_roles_on_authorizable_id"
  add_index "roles", ["authorizable_type"], :name => "index_roles_on_authorizable_type"
  add_index "roles", ["name"], :name => "index_roles_on_name"

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_version"
    t.integer  "role_version"
  end

  add_index "roles_users", ["role_id"], :name => "index_roles_users_on_role_id"
  add_index "roles_users", ["user_id"], :name => "index_roles_users_on_user_id"

  create_table "roles_users_versions", :id => false, :force => true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_version"
    t.integer  "role_version"
  end

  create_table "rotisserie_assignments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "rotisserie_discussion_id"
    t.integer  "rotisserie_post_id"
    t.integer  "round"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rotisserie_assignments", ["rotisserie_discussion_id"], :name => "index_rotisserie_assignments_on_rotisserie_discussion_id"
  add_index "rotisserie_assignments", ["rotisserie_post_id"], :name => "index_rotisserie_assignments_on_rotisserie_post_id"
  add_index "rotisserie_assignments", ["round"], :name => "index_rotisserie_assignments_on_round"
  add_index "rotisserie_assignments", ["user_id"], :name => "index_rotisserie_assignments_on_user_id"

  create_table "rotisserie_discussions", :force => true do |t|
    t.integer  "rotisserie_instance_id"
    t.string   "title",                  :limit => 250,                   :null => false
    t.text     "output"
    t.text     "description"
    t.text     "notes"
    t.integer  "round_length",                          :default => 2
    t.integer  "final_round",                           :default => 2
    t.datetime "start_date"
    t.string   "session_id"
    t.boolean  "active",                                :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "public",                                :default => true
    t.integer  "pushed_from_id"
  end

  add_index "rotisserie_discussions", ["active"], :name => "index_rotisserie_discussions_on_active"
  add_index "rotisserie_discussions", ["rotisserie_instance_id"], :name => "index_rotisserie_discussions_on_rotisserie_instance_id"
  add_index "rotisserie_discussions", ["title"], :name => "index_rotisserie_discussions_on_title"

  create_table "rotisserie_instances", :force => true do |t|
    t.string   "title",       :limit => 250,                   :null => false
    t.text     "output"
    t.text     "description"
    t.text     "notes"
    t.string   "session_id"
    t.boolean  "active",                     :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "public",                     :default => true
  end

  add_index "rotisserie_instances", ["title"], :name => "index_rotisserie_instances_on_title", :unique => true

  create_table "rotisserie_posts", :force => true do |t|
    t.integer  "rotisserie_discussion_id"
    t.integer  "round"
    t.string   "title",                    :limit => 250,                   :null => false
    t.text     "output"
    t.string   "session_id"
    t.boolean  "active",                                  :default => true
    t.integer  "parent_id"
    t.integer  "children_count"
    t.integer  "ancestors_count"
    t.integer  "descendants_count"
    t.integer  "position"
    t.boolean  "hidden"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "public",                                  :default => true
  end

  add_index "rotisserie_posts", ["active"], :name => "index_rotisserie_posts_on_active"
  add_index "rotisserie_posts", ["parent_id"], :name => "index_rotisserie_posts_on_parent_id"
  add_index "rotisserie_posts", ["position"], :name => "index_rotisserie_posts_on_position"
  add_index "rotisserie_posts", ["rotisserie_discussion_id"], :name => "index_rotisserie_posts_on_rotisserie_discussion_id"
  add_index "rotisserie_posts", ["round"], :name => "index_rotisserie_posts_on_round"

  create_table "rotisserie_trackers", :force => true do |t|
    t.integer  "rotisserie_discussion_id"
    t.integer  "rotisserie_post_id"
    t.integer  "user_id"
    t.string   "notify_description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rotisserie_trackers", ["rotisserie_discussion_id"], :name => "index_rotisserie_trackers_on_rotisserie_discussion_id"
  add_index "rotisserie_trackers", ["rotisserie_post_id"], :name => "index_rotisserie_trackers_on_rotisserie_post_id"
  add_index "rotisserie_trackers", ["user_id"], :name => "index_rotisserie_trackers_on_user_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "taggable_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["context"], :name => "index_taggings_on_context"
  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"
  add_index "taggings", ["taggable_id"], :name => "index_taggings_on_taggable_id"
  add_index "taggings", ["taggable_type"], :name => "index_taggings_on_taggable_type"
  add_index "taggings", ["tagger_id"], :name => "index_taggings_on_tagger_id"
  add_index "taggings", ["tagger_type"], :name => "index_taggings_on_tagger_type"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  add_index "tags", ["name"], :name => "index_tags_on_name"

  create_table "text_blocks", :force => true do |t|
    t.string   "name",                                                        :null => false
    t.string   "description",    :limit => 5242880,                           :null => false
    t.string   "mime_type",      :limit => 50,      :default => "text/plain"
    t.boolean  "active",                            :default => true
    t.boolean  "public",                            :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "pushed_from_id"
  end

  add_index "text_blocks", ["created_at"], :name => "index_text_blocks_on_created_at"
  add_index "text_blocks", ["mime_type"], :name => "index_text_blocks_on_mime_type"
  add_index "text_blocks", ["name"], :name => "index_text_blocks_on_name"
  add_index "text_blocks", ["updated_at"], :name => "index_text_blocks_on_updated_at"

  create_table "user_collection_versions", :force => true do |t|
    t.integer  "user_collection_id"
    t.integer  "version"
    t.integer  "owner_id"
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_version"
  end

  add_index "user_collection_versions", ["user_collection_id"], :name => "index_user_collection_versions_on_user_collection_id"

  create_table "user_collections", :force => true do |t|
    t.integer  "owner_id"
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_version"
    t.integer  "version"
  end

  create_table "user_collections_users", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "user_collection_id"
    t.integer "user_version"
    t.integer "user_collection_version"
  end

  create_table "user_collections_users_versions", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "user_collection_id"
    t.integer "user_version"
    t.integer "user_collection_version"
  end

  create_table "user_versions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "version"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "login"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.integer  "login_count",              :default => 0
    t.datetime "last_request_at"
    t.datetime "last_login_at"
    t.datetime "current_login_at"
    t.string   "last_login_ip"
    t.string   "current_login_ip"
    t.string   "oauth_token"
    t.string   "oauth_secret"
    t.string   "email_address"
    t.string   "tz_name"
    t.integer  "bookmark_id"
    t.integer  "karma"
    t.string   "attribution"
    t.string   "perishable_token"
    t.boolean  "default_show_annotations"
    t.boolean  "tab_open_new_items"
    t.string   "default_font_size"
  end

  add_index "user_versions", ["user_id"], :name => "index_user_versions_on_user_id"

  create_table "users", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "login"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token",                          :null => false
    t.integer  "login_count",              :default => 0,    :null => false
    t.datetime "last_request_at"
    t.datetime "last_login_at"
    t.datetime "current_login_at"
    t.string   "last_login_ip"
    t.string   "current_login_ip"
    t.string   "oauth_token"
    t.string   "oauth_secret"
    t.string   "email_address"
    t.string   "tz_name"
    t.integer  "bookmark_id"
    t.integer  "karma"
    t.string   "attribution"
    t.string   "perishable_token"
    t.boolean  "default_show_annotations"
    t.boolean  "tab_open_new_items"
    t.string   "default_font_size",        :default => "16"
    t.integer  "version"
  end

  add_index "users", ["email_address"], :name => "index_users_on_email_address"
  add_index "users", ["last_request_at"], :name => "index_users_on_last_request_at"
  add_index "users", ["login"], :name => "index_users_on_login"
  add_index "users", ["oauth_token"], :name => "index_users_on_oauth_token"
  add_index "users", ["persistence_token"], :name => "index_users_on_persistence_token"
  add_index "users", ["tz_name"], :name => "index_users_on_tz_name"

  create_table "vote_versions", :force => true do |t|
    t.integer  "vote_id"
    t.integer  "version"
    t.boolean  "vote",             :default => false
    t.integer  "voteable_id"
    t.string   "voteable_type"
    t.integer  "voter_id"
    t.string   "voter_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "voter_version"
    t.integer  "voteable_version"
  end

  add_index "vote_versions", ["vote_id"], :name => "index_vote_versions_on_vote_id"

  create_table "votes", :force => true do |t|
    t.boolean  "vote",             :default => false
    t.integer  "voteable_id"
    t.string   "voteable_type"
    t.integer  "voter_id"
    t.string   "voter_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "voter_version"
    t.integer  "voteable_version"
    t.integer  "version"
  end

  add_index "votes", ["voteable_id", "voteable_type"], :name => "fk_voteables"
  add_index "votes", ["voter_id", "voter_type", "voteable_id", "voteable_type"], :name => "uniq_one_vote_only", :unique => true
  add_index "votes", ["voter_id", "voter_type"], :name => "fk_voters"

end
