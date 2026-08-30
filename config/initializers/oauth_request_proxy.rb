# Rails 5.2 compatibility for OAuth signature verification with ims-lti / oauth gems.
#
# In Rails 5.2, ActionDispatch::Request includes Rack::Request::Helpers rather
# than inheriting from Rack::Request. Additionally, OAuth::RequestProxy::ActionControllerRequest
# attempts to read request.raw_post which evaluates to nil after Rails parameter parsing,
# dropping all POST parameters from the OAuth signature base string.
#
# Using OAuth::RequestProxy::RackRequest for ActionDispatch::Request correctly reads
# parameters via request.POST and computes accurate signatures for LTI launches.

require 'oauth/request_proxy/rack_request'

OAuth::RequestProxy.available_proxies[ActionDispatch::Request] = OAuth::RequestProxy::RackRequest
