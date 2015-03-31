ActiveAdmin.register Error,
  sort_order: :created_at_desc do
  actions :all, except: [:new, :create, :update, :edit, :destroy]

  menu priority: 1000

  index do
    column :class_name
    column(:message) { |e| link_to e.message, admin_error_path(e) }
    column 'URL', :target_url
    column :time, :created_at
    actions
  end

end
