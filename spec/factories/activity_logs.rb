FactoryBot.define do
  factory :activity_log do
    user { nil }
    exercise { nil }
    workout { nil }
    workout_offering { nil }
    activity { "MyString" }
    ip_address { "MyString" }
  end
end
