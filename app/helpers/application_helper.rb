module ApplicationHelper

  # -------------------------------------------------------------
  # For using nested layouts
  def inside_layout(layout = 'wrapper', &block)
    render :inline => capture_haml(&block), :layout => "layouts/#{layout}"
  end


  # -------------------------------------------------------------
  def controller_stylesheet_link_tag
    c = params[:controller]
    stylesheet_link_tag c if Rails.application.assets.find_asset("#{c}.css")
  end


  # -------------------------------------------------------------
  def controller_javascript_include_tag
    c = params[:controller]
    javascript_include_tag c if Rails.application.assets.find_asset("#{c}.js")
  end


  # -------------------------------------------------------------
  # Returns the correct twitter bootstrap class mapping for different
  # types of flash messages
  # 
  FLASH_CLASS = {
      success: 'alert-success',
      error:   'alert-error',
      alert:   'alert-block',
      notice:  'alert-info'
  }
  def flash_class(level)
    FLASH_CLASS[level] || level.to_s
  end


  # -------------------------------------------------------------
  # Creates a link styled as aBootstrap button.
  #
  def button_link(label, destination = '#', icon = nil, options = {})
    options[:class] = options[:class] || 'btn'
    if options[:btn]
      options[:class] = options[:class] + ' btn-' + options[:btn]
      options.delete(:btn)
    end
    text = label
    if !icon.nil?
      text = content_tag(:i, nil, class: "icon-#{icon}") + ' ' + text
    end
    link_to text, destination, options       
  end

end
