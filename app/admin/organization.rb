ActiveAdmin.register Organization do
  menu parent: 'University-oriented', priority: 20
  permit_params :name, :abbreviation
  actions :all, except: [:destroy]

  index do
    id_column
    column(:name) { |org| link_to org.name, admin_organization_path(org) }
    column :abbreviation
    column :created_at
    actions
  end

  sidebar 'Courses', only: :show do
    table_for organization.courses do
      column :number
      column(:name) { |c| link_to c.name, admin_course_path(c) }
    end
  end

end
