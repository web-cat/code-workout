ActiveAdmin.register User do
  active_admin_import

  permit_params :first_name, :last_name, :email,
    :confirmed_at, :global_role_id, :avatar

  index do
    selectable_column
    id_column
    column :last_name
    column :first_name
    column(:email) { |u| link_to u.email, 'mailto:' + u.email }
    column :avatar
    column :confirmed, :confirmed_at
    column :last_login, :last_sign_in_at
    column 'Last IP', :last_sign_in_ip
    actions
  end

  sidebar 'Teaching Courses', only: :show,
    if: proc{ user.instructor_course_offerings.any? } do
    table_for user.instructor_course_offerings do
      column(:term) {|c| link_to c.term.display_name, admin_term_path(c.term)}
      column :offering do |c|
        link_to c.display_name, admin_course_offering_path(c)
      end
    end
  end

  sidebar 'Grading Courses', only: :show,
    if: proc{ user.grader_course_offerings.any? } do
    table_for user.grader_course_offerings do
      column(:term) {|c| link_to c.term.display_name, admin_term_path(c.term)}
      column :offering do |c|
        link_to c.display_name, admin_course_offering_path(c)
      end
    end
  end

end
