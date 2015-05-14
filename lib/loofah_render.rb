require 'loofah'

# =============================================================================
# This is a custom RedCarpet renderer that uses Loofah to sanitize the
# generated HTML to make sure it is safe, preventing any XSS or HTML
# injection attacks.  We need this since we will be rendering user-generated
# markdown/html input.
#
class LoofahRender < Redcarpet::Render::HTML
  def postprocess(document)
    Loofah.fragment(document).scrub!(:strip).to_s.html_safe
  end
end
