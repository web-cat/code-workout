# == Schema Information
#
# Table name: coding_prompts
#
#  id           :integer          not null, primary key
#  created_at   :datetime
#  updated_at   :datetime
#  class_name   :string(255)
#  wrapper_code :text             not null
#  test_script  :text             not null
#  method_name  :string(255)
#  starter_code :text
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :coding_prompt do
    # Can't validate during create for some reason, because of actable
    to_create {|instance| instance.save(validate: false) }
    after :create do |cp|
      # Force validation now, after actable relationship is set up
      cp.save!
    end
  end
end
