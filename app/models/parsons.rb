#  create_table "parsons", force: :cascade do |t|
# t.string   "title"
# t.text     "instructions"
# t.text     "initial"
# t.text     "unittest", default: ""
# t.string   "type"
# t.text     "concepts" 
# t.integer  "order"
# t.text     "parsonsConfig" 
# t.timestamps null: false
# end

class Parsons < ActiveRecord::Base
#~ Relationships ............................................................

    serialize :concepts, Array
    serialize :parsonsConfig, Hash
end

