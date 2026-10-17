# frozen_string_literal: true

ActiveAdmin.register Error do
  config.sort_order = 'count_desc'

  actions :all, except: [:new, :create, :update, :edit, :destroy]

  menu priority: 1000

  filter :class_name
  filter :count
  filter :last_seen_at
  filter :created_at

  index do
    column :count, sortable: :count
    column :class_name, sortable: :class_name
    column(:message) { |e| link_to e.message.to_s.truncate(100), admin_error_path(e) }
    column 'Last URL', :target
    column :last_seen_at, sortable: :last_seen_at
    column 'First Seen', :created_at, sortable: :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :count
      row :fingerprint
      row :class_name
      row :status
      row :message
      row :target
      row :referrer
      row :params
      row :user_agent do |e|
        e.raw_user_agent
      end
      row 'First Seen', :created_at
      row :last_seen_at
      row :updated_at
      row :trace do |e|
        pre e.trace
      end
    end
    active_admin_comments
  end
end
