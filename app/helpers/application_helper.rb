module ApplicationHelper
  include ActionView::Helpers::JavaScriptHelper
  include ActionView::Helpers::UrlHelper


  # -------------------------------------------------------------
  # For using nested layouts
  def inside_layout(layout = 'wrapper', &block)
    render :inline => capture_haml(&block), :layout => "layouts/#{layout}"
  end


  # -------------------------------------------------------------
  def controller_stylesheet_link_tag
    c = params[:controller] || controller_name
    stylesheet_link_tag c if (Rails.application.assets || ::Sprockets::Railtie.build_environment(Rails.application)).find_asset("#{c}.css")
  end


  # -------------------------------------------------------------
  def controller_javascript_include_tag
    c = params[:controller] || controller_name
    javascript_include_tag c if (Rails.application.assets || ::Sprockets::Railtie.build_environment(Rails.application)).find_asset("#{c}.js")
  end

  # -------------------------------------------------------------
  def dropdown_button_tag(*args, &block)
    if block_given?
      options = args.first || {}
      dropdown_button_tag(capture(&block), options)
    else
      content = args.first
      options = args.second || {}

      if options[:class]
        options[:class] += ' dropdown-toggle'
      else
        options[:class] = 'dropdown_toggle'
      end

      if options[:data]
        options[:data][:toggle] = 'dropdown'
      else
        options[:data] = { toggle: 'dropdown' }
      end

      options[:href] = '#'

      content_tag :a, options do
        raw(content + ' <span class="caret"></span>'.html_safe)
      end
    end
  end


  # -------------------------------------------------------------
  TEASER_LENGTH = 140
  def teaser(text, length = TEASER_LENGTH)
    if text.blank?
      ""
    else
      truncate_html(markdown(text), length: length, omission: '...')
    end
  end


  # -------------------------------------------------------------
  # Returns the correct twitter bootstrap class mapping for different
  # types of flash messages
  #
  FLASH_CLASS = {
      success:     'alert-success',
      'success' => 'alert-success',
      error:       'alert-danger',
      'error'   => 'alert-danger',
      alert:       'alert-warning',
      'alert'   => 'alert-warning',
      block:       'alert-warning',
      'block'   => 'alert-warning',
      warning:     'alert-warning',
      'warning' => 'alert-warning',
      notice:      'alert-info',
      'notice'  => 'alert-info',
      info:        'alert-info',
      'info'    => 'alert-info'
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
      'danger'  => 'exclamation-sign',
      'alert'   => 'warning-sign',
      'block'   => 'warning-sign',
      'warning' => 'warning-sign',
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
      if !tag.start_with?('glyphicon-', 'fa-')
        tag = tag.downcase.sub(/[^a-zA-Z0-9_-].*$/, '')
        name = ICON_NAME[tag] || tag
        if name.nil?
          name
        else
          'glyphicon-' + name
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
    cls = icon_name_for(name) + ' icon-fixed-width'
    if cls.nil?
      ''
    else
      if cls.start_with?('glyphicon-')
        cls = 'glyphicon ' + cls
      elsif cls.start_with?('fa-')
        cls = 'fa ' + cls
      end
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
  def button_to_with_style(
    name = nil, options = nil, html_options = nil, &block)
    if !options
      options = {}
    elsif !options.is_a?(Hash)
      html_options ||= {}
    end
    opts = html_options || options
    opts[:class] = opts[:class] || 'btn'
    if opts[:btn]
      opts[:class] = opts[:class] + ' btn-' + opts.delete(:btn)
    end
    if opts[:size]
      opts[:class] = opts[:class] + ' btn-' + opts.delete(:size)
    end
    if opts[:color]
      opts[:class] = opts[:class] + ' btn-' + opts.delete(:color)
    else
      opts[:class] = opts[:class] + ' btn-default'
    end
    puts "options = #{options}"
    puts "html_options = #{html_options}"
    button_to_without_style(name, options, html_options, &block)
  end
  alias_method :button_to_without_style, :button_to
  alias_method :button_to, :button_to_with_style


  # -------------------------------------------------------------
  # Creates a link styled as aBootstrap button.
  #
  def button_link(label, destination = '#', options = {})
    options[:class] = options[:class] || 'btn'
    if options[:btn]
      options[:class] = options[:class] + ' btn-' + options.delete(:btn)
    end
    if options[:size]
      options[:class] = options[:class] + ' btn-' + options.delete(:size)
    end
    if options[:color]
      options[:class] = options[:class] + ' btn-' + options.delete(:color)
    else
      options[:class] = options[:class] + ' btn-default'
    end
    text = label
    if options[:icon]
      text = icon_tag_for(options[:icon]) + ' ' + text
    end
    link_to text, destination, options
  end


  # -------------------------------------------------------------
  # Creates a difficulty belt image.
  #
  BELT_COLOR = ['White', 'Yellow', 'Orange', 'Green', 'Blue', 'Violet',
    'Brown', 'Black']
  def difficulty_image(val)
    levels = 8
    increments = 100.0/8
    if val <= 0
      num = 1
    elsif val > 100
      num = 8
    else
      num = val / (increments).round
    end
    if num == 0
      color = 'White'
    else
      color = BELT_COLOR[num]
    end
    image_tag('belt' + num.to_s + '.png',
      alt: color.to_s + ' Belt (' + val.to_s + ')',
      class: 'difficulty')
  end


  # -------------------------------------------------------------
  def n_to_s(val)
    if val == val.to_i
      val.to_i.to_s
    else
      val.round(1).to_s
    end
  end

end
