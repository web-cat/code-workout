ActiveAdmin.register_page 'Dashboard' do

  menu priority: 1, label: proc{ I18n.t('active_admin.dashboard') }

  content title: 'Administrator Dashboard' do

    panel 'Recent Errrors' do
      table_for Error.order('created_at desc').first(6) do
        column(:time) { |e| l user_time(current_user, e.updated_at) }
        column :class_name
        column(:message) do |e|
          link_to e.message, admin_error_path(e)
        end
        column(:params) { |e| e.params }
      end
      a 'View log file', href: '/log_file'
    end

    columns do

      column do
        term = Term.current_term
        panel 'Current Term' do
          table_for [term] do
            column(:name) { |t| link_to t.display_name, admin_term_path(t) }
            column :starts_on
            column :ends_on
          end
        end
        panel "#{term.display_name} Course Offerings" do
          table_for term.course_offerings do
            column :course
            column :offering do |c|
              link_to c.label, admin_course_offering_path(c)
            end
            column :instructor  do |c|
              i = c.instructors.first
              if i
                link_to i.display_name, admin_user_path(i)
              end
            end
          end
        end
      end

      column do
        panel 'Recent Users' do
          table_for User.where('last_sign_in_at is not null').
            order('last_sign_in_at desc').first(20) do
            column(:name) { |u| link_to u.display_name, admin_user_path(u) }
            column(:email) { |u| link_to u.email, 'mailto:' + u.email }
            column :last_login, :last_sign_in_at
            column 'Last IP', :last_sign_in_ip
          end
        end
      end

    end

  end

end
