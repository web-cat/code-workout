module DeviseHelper

  # -------------------------------------------------------------
  def devise_error_messages!
    return "" if resource.nil? || resource.errors.empty?

    messages = resource.errors.full_messages.map do |msg|
        content_tag :li,
          icon_tag_for(:error, class: 'icon-li') + msg
    end
    messages = messages.join
    sentence = I18n.t("errors.messages.not_saved",
                      :count => resource.errors.count,
                      :resource => resource_name)

    html = <<-HTML
<div class="alert alert-error">
<p>#{sentence}</p>
<ul class="icons-ul">#{messages}</ul>
</div>
HTML

    html.html_safe
  end

end
