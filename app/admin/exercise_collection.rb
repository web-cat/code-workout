ActiveAdmin.register ExerciseCollection do
  includes :user_group, :license

  menu parent: 'Gym-oriented', priority: 20

  index do
    id_column
    column :name do |ec|
      link_to ec.name, admin_exercise_collection_path(ec)
    end
    column :description
    column :license
    column :created_at
    column :updated_at
    actions
  end

  sidebar 'Exercises', only: :show do
    table_for exercise_collection.exercises do
      column :id
      column(:name) { |e| link_to e.display_name, admin_exercise_path(e) }
    end
  end
end
