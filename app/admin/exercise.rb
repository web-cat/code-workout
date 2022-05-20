ActiveAdmin.register Exercise do
  includes :current_version, :owners

  menu parent: 'Gym-oriented', priority: 10
  permit_params :name, :current_version, owner_ids: []

  index do
    id_column
    column :name, sortable: 'exercises.name'
    column :current_version, sortable: 'current_versions.version' do |e|
      e.current_version.version
    end
    column :is_public
    column :created_at
    column :updated_at
    column :exercise_collection
    actions
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :name
      f.input :is_public
      f.input :experience
      f.input :exercise_family
      f.input :current_version, as: :select, collection: (f.object.exercise_versions.map { |v| [v.version, v.id] })
      f.input :exercise_collection
      f.input :question_type
      f.input :owners, as: :select, multiple: true,
        hint: "Hold down Cmd/Ctrl while selecting or unselecting owners<br>
        Current owners: #{f.object.owners.map(&:display_name).join(', ')}".html_safe,
        collection: User.all.sort_by(&:display_name)
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row(:current_version) { |e| e.current_version.text_representation }
      row :is_public
      row :created_at
      row :updated_at
      row(:owners) { |e|
        e.owners.map { |o| link_to("#{o.display_name}", admin_user_path(o)) }
      }
    end
  end
end
