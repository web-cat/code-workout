# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')
Rails.application.config.assets.paths << Rails.root.join('public')

Rails.application.config.assets.precompile = [
  Proc.new { |filename, path| 
    path =~ /app\/assets/ && 
      path !~ /bootstrap-social/ &&
      path !~ /active_admin/ &&
      %w(.js .css).include?(File.extname(filename))
  }, /application.(css|.js)$/,
  %w(*.png *.jpg *.jpeg *.gif *.mustache.html, *.ico)
]
