namespace :documentation do
  namespace :api do
    desc "Generate config for iodocs"
    task :generate_config => :environment do
      base_config = File.read(File.join('data', 'api.yml'))
      config = YAML::load(ERB.new(base_config).result(binding))

      puts JSON.pretty_generate(config)
    end
  end
end
