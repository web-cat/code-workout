# == Schema Information
#
# Table name: multiple_choice_prompts
#
#  id             :integer          not null, primary key
#  allow_multiple :boolean          default(FALSE), not null
#  is_scrambled   :boolean          default(TRUE), not null
#

FactoryGirl.define do
  factory :multiple_choice_prompt do
    allow_multiple false
    is_scrambled true

    # Can't validate during create for some reason, because of actable
    to_create {|instance| instance.save(validate: false) }
    after :create do |mcp|
      # Force validation now, after actable relationship is set up
      mcp.save!
    end
  end
end
