# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/osx'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'markdown'
  app.icon = 'markdown.icns'
  app.files_dependencies 'app/markdown_text_storage.rb' => 'app/styles.rb'
end
