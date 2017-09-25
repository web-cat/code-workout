class Users::SessionsController < Devise::SessionsController
  def new
    if params[:redirect_to].present?
      self.resource = resource_class.new(sign_in_params)
      store_location_for(resource, params[:redirect_to])
    end
    super
  end
end
