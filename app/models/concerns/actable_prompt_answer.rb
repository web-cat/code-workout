# app/models/concerns/actable_prompt_answer.rb
module ActablePromptAnswer
  extend ActiveSupport::Concern

  included do
    acts_as :prompt_answer, autosave: false

    after_commit :persist_prompt_answer_association, on: [:create, :update]
  end

  private

  def persist_prompt_answer_association
    att_id = self.attempt.andand.id || self.acting_as.andand.attempt.andand.id || self.acting_as.andand.attempt_id
    prm_id = self.prompt.andand.id || self.acting_as.andand.prompt.andand.id || self.acting_as.andand.prompt_id

    if att_id.present? && prm_id.present?
      existing_id = ActiveRecord::Base.connection.select_value(
        "SELECT id FROM prompt_answers WHERE attempt_id = #{att_id.to_i} AND prompt_id = #{prm_id.to_i}"
      )
      if existing_id
        ActiveRecord::Base.connection.execute(
          "UPDATE prompt_answers SET actable_id = #{self.id}, actable_type = '#{self.class.name}' WHERE id = #{existing_id}"
        )
      else
        ActiveRecord::Base.connection.execute(
          "INSERT INTO prompt_answers (attempt_id, prompt_id, actable_id, actable_type) " \
          "VALUES (#{att_id.to_i}, #{prm_id.to_i}, #{self.id}, '#{self.class.name}')"
        )
      end
    end
  end
end
