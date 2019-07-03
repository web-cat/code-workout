# == Schema Information
#
# Table name: users
#
#  id                       :integer          not null, primary key
#  email                    :string(255)      default(""), not null
#  encrypted_password       :string(255)      default(""), not null
#  reset_password_token     :string(255)
#  reset_password_sent_at   :datetime
#  remember_created_at      :datetime
#  sign_in_count            :integer          default(0), not null
#  current_sign_in_at       :datetime
#  last_sign_in_at          :datetime
#  current_sign_in_ip       :string(255)
#  last_sign_in_ip          :string(255)
#  confirmation_token       :string(255)
#  confirmed_at             :datetime
#  confirmation_sent_at     :datetime
#  created_at               :datetime
#  updated_at               :datetime
#  first_name               :string(255)
#  last_name                :string(255)
#  global_role_id           :integer          not null
#  avatar                   :string(255)
#  slug                     :string(255)      default(""), not null
#  current_workout_score_id :integer
#  time_zone_id             :integer
#
# Indexes
#
#  index_users_on_confirmation_token        (confirmation_token) UNIQUE
#  index_users_on_current_workout_score_id  (current_workout_score_id) UNIQUE
#  index_users_on_email                     (email) UNIQUE
#  index_users_on_global_role_id            (global_role_id)
#  index_users_on_reset_password_token      (reset_password_token) UNIQUE
#  index_users_on_slug                      (slug) UNIQUE
#  index_users_on_time_zone_id              (time_zone_id)
#

FactoryBot.define do

 factory :user do
   first_name { 'Joe' }
   last_name  { 'Hokie' }
   email      { 'hokie@codeworkout.org' }
   password   { 'hokiehokie' }
#    password_confirmation 'hokiehokie'
   global_role { GlobalRole.regular_user }

   factory :confirmed_user do
      confirmed_at { Time.now }

     factory :instructor_user do
       global_role { GlobalRole.instructor }
     end

     factory :admin do
       first_name { 'Admin' }
       last_name  { 'Istrator' }
       email      { 'admin@codeworkout.org' }
       password   { 'adminadmin' }
#       passsword_confirmation 'adminadmin'
       global_role { GlobalRole.administrator }
     end
   end
 end

end
