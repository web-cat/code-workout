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
      block:   'alert-block',
      notice:  'alert-info',
      info:    'alert-info'
  }
  def flash_class_for(level)
    FLASH_CLASS[level] || level.to_s
  end


  # -------------------------------------------------------------
  # Returns a FontAwesome icon name (without the prefix), if there
  # is one associated with the tag provided
  # 
  ICON_NAME = {
      'success' => 'ok-sign',
      'error'   => 'exclamation-sign',
      'alert'   => 'warning-sign',
      'block'   => 'warning-sign',
      'notice'  => 'info-sign',
      'info'    => 'info-sign',

      'show'    => 'zoom-in',
      'edit'    => 'edit',
      'delete'  => 'trash',
      'destroy' => 'trash',
      'back'    => 'reply',
      'new'     => 'plus',
      'add'     => 'plus',
      'ok'      => 'ok-sign',
      'cancel'  => 'remove-sign',
      'yes'     => 'thumbs-up',
      'no'      => 'thumbs-down',
      'like'    => 'thumbs-up',
      'unlike'  => 'thumbs-down'
  }
  def icon_name_for(tag)
    if !tag.nil?
      tag = tag.to_s
      if !tag.start_with?('icon-')
        tag = tag.downcase.sub(/[^a-zA-Z0-9_-].*$/, '')
        name = ICON_NAME[tag]
        if name.nil?
          name
        else
          'icon-' + name
        end
      else
        tag
      end
    else
      tag
    end
  end


  # -------------------------------------------------------------
  def icon_tag_for(name, options = {})
    cls = icon_name_for(name)
    if cls.nil?
      ''
    else
      if options[:class]
        cls = options[:class] + ' ' + cls
      else
        options[:class] = cls
      end
      content_tag :i, nil, class: cls
    end
  end


  # -------------------------------------------------------------
  def icon2x_tag_for(name, options = {})
    if options[:class]
      options[:class] += ' icon-2x'
    else
      options[:class] = 'icon-2x'
    end
    icon_tag_for(name, options)
  end


  # -------------------------------------------------------------
  def icon4x_tag_for(name, options = {})
    if options[:class]
      options[:class] += ' icon-4x'
    else
      options[:class] = 'icon-4x'
    end
    icon_tag_for(name, options)
  end


  # -------------------------------------------------------------
  # Creates a link styled as aBootstrap button.
  #
  def button_link(label, destination = '#', options = {})
    options[:class] = options[:class] || 'btn'
    if options[:btn]
      options[:class] = options[:class] + ' btn-' + options[:btn]
      options.delete(:btn)
    end
    text = label
    icon = options[:icon] ||= label
    if !icon.nil?
      text = icon_tag_for(icon) + ' ' + text
    end
    link_to text, destination, options       
  end

end
