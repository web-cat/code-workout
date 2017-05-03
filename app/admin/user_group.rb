ActiveAdmin.register UserGroup do
  includes :memberships, :exercise_collection
  active_admin_import

  menu parent: 'Users', priority: 20

  index do
    id_column
    column :name
    column :exercise_collection
    actions
  end

  sidebar 'Users', only: :show do
    table_for user_group.memberships do
      column :id
      column(:user) { |m| link_to m.user.display_name, admin_user_path(m.user) }
    end
  end
end
