ActiveAdmin.register Term do
  menu parent: 'University-oriented', priority: 10
  permit_params :year, :starts_on, :ends_on, :season
  actions :all, except: [:destroy]

  index do
    id_column
    column 'Season', :season_name
    column :year
    column :starts_on
    column :ends_on
    actions
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :season, as: :radio, collection: Term::SEASONS
      f.input :year
      f.input :starts_on, as: :datepicker
      f.input :ends_on, as: :datepicker
    end
    f.actions
  end

  sidebar 'Course Offerings', only: :show do
    table_for term.course_offerings do
      column(:course) do |c|
        link_to c.course.number_and_org, admin_course_path(c.course)
      end
      column(:label) { |c| link_to c.label, admin_course_offering_path(c) }
    end
  end

end
