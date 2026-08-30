# PassPort Protocol Configuration

# List of allowed domain patterns for external extension managers.
# Supports simple string matches or regex patterns.
PASSPORT_WHITELIST = [
  /\A([a-z0-9-]+)\.cs\.vt\.edu\z/i,
  /\A([a-z0-9-]+)\.vt\.edu\z/i,
  'localhost'
]

# Properties requested from the external extension manager.
# These will be sent back in the registration response.
PASSPORT_REQUESTED_PROPERTIES = [
    "canvas_course_id",
    "lti_user_id",
    "broker_user_id",
    "canvas_user_id",
    "email",
    "broker_assignment_id",
    "canvas_assignment_id",
    "title",
    "external_url"
]
