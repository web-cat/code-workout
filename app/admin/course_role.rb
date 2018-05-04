ActiveAdmin.register CourseRole do
  actions :all, except: [:destroy]

  menu parent: 'University-oriented', priority: 100

end
