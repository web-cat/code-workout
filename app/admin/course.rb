ActiveAdmin.register Course, sort_order: :number_asc do
  includes :organization

  menu parent: 'University-oriented', priority: 30
  permit_params :name, :number, :organization_id

  index do
    id_column
    column(:number) { |c| link_to c.number, admin_course_path(c) }
    column(:name) { |c| link_to c.name, admin_course_path(c) }
    column :organization, sortable: 'organizations.name'
    column :creator
    column :created_at
    actions
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :organization
      f.input :number
      f.input :name
      f.input :is_hidden
    end
    f.actions
  end

  sidebar 'Offerings', only: :show do
    table_for course.course_offerings do
      column(:term) { |c| c.term.display_name }
      column(:name) do |c|
        link_to c.display_name, admin_course_offering_path(c)
      end
    end
  end

  sidebar 'Privileged Users', only: :show,
    if: proc{ course.user_group } do
      table_for course.user_group.users do
        column :name do |u|
          link_to u.display_name, admin_user_path(u)
        end
      end
    end
end
