ActiveAdmin.register WorkoutOffering do
  includes :workout, :course_offering

  menu parent: 'University-oriented', priority: 40
  permit_params :course_offering_id, :workout_id, :opening_date, :soft_deadline, :hard_deadline

  index do
    id_column
    column :course_offering_id, sortable: 'course_offering.label' do |wo|
      link_to wo.course_offering.display_name_with_term,
        admin_course_offering_path(wo.course_offering)
    end
    column :workout_id, sortable: 'workout.name' do |wo|
      wo.workout.name
    end
    column :opening_date
    column :soft_deadline
    column :hard_deadline
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :course_offering_id, sortable: 'course_offering.label'
      row :workout_id
      row :opening_date
      row :soft_deadline
      row :hard_deadline
      row :created_at
      row :updated_at
    end

    # panel 'Roster' do
    #   table_for course_offering.students do
    #     column :name, :display_name
    #     column :email
    #   end
    # end

  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :course_offering, collection: (current_user.global_role.is_admin? ? CourseOffering.all : current_user.managed_course_offerings)
      f.input :workout
      f.input :opening_date, as: :datepicker
      f.input :soft_deadline, as: :datepicker
      f.input :hard_deadline, as: :datepicker
    end
    f.actions
  end

  # sidebar 'Instructors', only: :show,
  #   if: proc{ course_offering.instructors.any? } do
  #   table_for course_offering.instructors do
  #     column(:name) { |i| link_to i.display_name, admin_user_path(i) }
  #     column(:email) { |i| link_to i.email, 'mailto:' + i.email }
  #   end
  # end
  #
  # sidebar 'Graders', only: :show,
  #   if: proc{ course_offering.graders.any? } do
  #   table_for course_offering.graders do
  #     column(:name) { |i| link_to i.display_name, admin_user_path(i) }
  #     column(:email) { |i| link_to i.email, 'mailto:' + i.email }
  #   end
  # end

end
