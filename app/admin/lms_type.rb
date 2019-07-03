ActiveAdmin.register LmsType do
  menu parent: 'LMS config', priority: 10
  permit_params :name
  actions :all, except: [:destroy]

  index do
    id_column
    column(:name) { |lms| link_to lms.name, admin_lms_type_path(lms) }
    column :created_at
    actions
  end
end
