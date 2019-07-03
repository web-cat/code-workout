ActiveAdmin.register User do
  includes :memberships

  menu parent: 'Users', priority: 10
  permit_params :first_name, :last_name, :email,
    :slug, :global_role, :time_zone, :avatar,
    :resest_password_token, :reset_password_sent_at,
    :confirmation_token, memberships_attributes: [
      :id, :user_group_id
    ]

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

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :first_name
      f.input :last_name
      f.input :email
      f.input :slug
      f.input :global_role
      f.input :time_zone
      f.input :reset_password_token
      f.input :reset_password_sent_at
      f.input :confirmation_token
    end
    f.inputs 'Group Memberships' do
      f.has_many :memberships do |g|
        g.input :user_group
      end
    end
    f.actions
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

  sidebar 'User Groups', only: :show,
    if: proc{ user.memberships.any? } do
      table_for user.user_groups do
        column :name do |g|
          link_to g.name, admin_user_group_path(g)
        end
      end
    end
end
