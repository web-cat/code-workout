ActiveAdmin.register LicensePolicy do
    includes :licenses

    menu priority: 1000
    permit_params :name, :description, :is_public, :can_fork,
      licenses_attributes: [ :id, :name, :description ]

    form do |f|
      f.semantic_errors
      f.inputs
      f.inputs 'Licenses' do
        f.has_many :licenses do |license|
          license.input :name
          license.input :description, placeholder: 'The license text can go here...'
        end
      end
      f.actions
    end
end
