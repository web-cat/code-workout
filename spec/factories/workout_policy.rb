# == Schema Information
#
# Table name: workout_policies
#
#  id                                      :integer          not null, primary key
#  hide_thumbnails_before_start            :boolean
#  hide_feedback_before_finish             :boolean
#  hide_compilation_feedback_before_finish :boolean
#  no_review_before_close                  :boolean
#  hide_feedback_in_review_before_close    :boolean
#  hide_thumbnails_in_review_before_close  :boolean
#  no_hints                                :boolean
#  no_faq                                  :boolean
#  name                                    :string(255)
#  created_at                              :datetime
#  updated_at                              :datetime
#

FactoryGirl.define do
  factory :workout_policy do
    name "my policy"
    invisible_before_review false

    after(:create) do |wpolicy|
        create(:workout_offering, workout_policy: wpolicy)
    end
  end
end
