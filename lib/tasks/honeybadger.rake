# force honeybadger to load environment so SECRETS can be read
namespace :honeybadger do
  task :deploy => [:environment]
end
