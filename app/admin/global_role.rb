ActiveAdmin.register GlobalRole do
  actions :all, except: [:new, :create, :edit, :update, :destroy]

  menu parent: 'University-oriented', priority: 200

end
