class CreateAttemptsTagUserScores < ActiveRecord::Migration
  def change
    # HABTM table attempts <-> tag_user_scores (many to many)
    create_table :attempts_tag_user_scores, id: false do |t|
      t.belongs_to :attempt, required: true
      t.belongs_to :tag_user_score, required: true

      t.index [:attempt_id, :tag_user_score_id], unique: true,
        name: 'attempts_tag_user_scores_idx'
    end
  end
end
