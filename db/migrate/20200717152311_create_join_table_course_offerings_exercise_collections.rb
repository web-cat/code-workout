class CreateJoinTableCourseOfferingsExerciseCollections < ActiveRecord::Migration
  def change
    create_join_table :course_offerings, :exercise_collections do |t|
      t.index [:course_offering_id, :exercise_collection_id], name: 'course_offering_collection'
      t.index [:exercise_collection_id, :course_offering_id], name: 'collection_course_offering'
    end
  end
end
