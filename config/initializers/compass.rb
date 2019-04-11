Compass.add_project_configuration(File.join(Rails.root, "config", "compass.config"))
# If you have any compass plugins, require them here.
require 'ninesixty'

Compass.configure_sass_plugin!
Compass.handle_configuration_change!