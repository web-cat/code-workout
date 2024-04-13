class ParsonsPrompt < ActiveRecord::Base
    belongs_to :parsons
    belongs_to :exercise_version

    store_accessor :assets, :code, :test
  end