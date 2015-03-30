class ApplicationResponder < ActionController::Responder
  include Responders::FlashResponder
  include Responders::HttpCacheResponder

  # Redirects resources to the collection path (index action) instead
  # of the resource path (show action) for POST/PUT/DELETE requests.
  # include Responders::CollectionResponder

  # Allows to use a callable object as the redirect location with respond_with,
  # eg a route that requires persisted objects when the validation may fail.
  # include Responders::LocationResponder
end
