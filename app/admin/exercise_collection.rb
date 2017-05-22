ActiveAdmin.register ExerciseCollection do
  includes :user_group, :user, :license, :course_offering

  menu parent: 'Gym-oriented', priority: 20

  index do
    id_column
    column(:name) { |ec| link_to ec.name, admin_exercise_collection_path(ec) }
    column :description
    column :license
    column :user
    column :user_group
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row :id
      row(:name) { |ec| link_to ec.name, admin_exercise_collection_path(ec) }
      row :description
      row :license
      row 'owned_by' do |ec|
        if ec.user
          link_to ec.user.display_name, admin_user_path(ec.user)
        elsif ec.user_group
          link_to ec.user_group.name, admin_user_group_path(ec.user_group)
        end
      end
    end
  end

  sidebar 'Exercises', only: :show do
    table_for exercise_collection.exercises do
      column :id
      column(:name) { |e| link_to e.display_name, admin_exercise_path(e) }
    end
  end

  sidebar 'Collection owners', only: :show,
    if: proc{ exercise_collection.user_group.andand.users.any? } do
      table_for exercise_collection.user_group.users do
        column :name do |u|
          link_to u.display_name, admin_user_path(u)
        end
      end
    end
end
