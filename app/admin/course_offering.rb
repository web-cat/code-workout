ActiveAdmin.register CourseOffering do
  includes :course, :term
  active_admin_import

  menu parent: 'University-oriented', priority: 40
  permit_params :course_id, :term_id, :name, :label, :url,
    :self_enrollment_allowed

  index do
    id_column
    column :course, sortable: 'courses.number' do |c|
      link_to c.course.number_and_org, admin_course_path(c.course)
    end
    column :term, sortable: 'term.ends_on' do |c|
      link_to c.term.display_name, admin_term_path(c.term)
    end
    column :label do |c|
      link_to c.label, admin_course_offering_path(c)
    end
    column 'Self-enroll?', :self_enrollment_allowed
    column(:url) { |c| link_to c.url, c.url }
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :course
      row :term
      row :label
      row(:url) { |c| link_to c.url, c.url }
      row :self_enrollment_allowed
      row :created_at
      row :updated_at
    end

    panel 'Roster' do
      table_for course_offering.students do
        column :name, :display_name
        column :email
      end
    end

  end

  sidebar 'Instructors', only: :show,
    if: proc{ course_offering.instructors.any? } do
    table_for course_offering.instructors do
      column(:name) { |i| link_to i.display_name, admin_user_path(i) }
      column(:email) { |i| link_to i.email, 'mailto:' + i.email }
    end
  end

  sidebar 'Graders', only: :show,
    if: proc{ course_offering.graders.any? } do
    table_for course_offering.graders do
      column(:name) { |i| link_to i.display_name, admin_user_path(i) }
      column(:email) { |i| link_to i.email, 'mailto:' + i.email }
    end
  end

end
