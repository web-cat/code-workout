ActiveAdmin.register UserGroup do
  includes :memberships, :exercise_collection

  menu parent: 'Users', priority: 20
  permit_params :name, memberships_attributes: [
    :id, :user_id
  ]

  index do
    id_column
    column :name do |g|
      link_to g.name, admin_user_group_path(g)
    end
    column :exercise_collection
    actions
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :name
    end
    f.inputs 'Members' do
      f.has_many :memberships do |m|
        m.input :user
      end
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :exercise_collection
      row :course
      row :created_at
      row :updated_at
    end
  end

  sidebar 'Members', only: :show do
    table_for user_group.memberships do
      column :id
      column(:user) { |m| link_to m.user.display_name, admin_user_path(m.user) }
    end
  end
end
