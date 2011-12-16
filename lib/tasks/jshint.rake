namespace :jshint do
  task :require do
    sh "which jshint" do |ok, res|
      fail 'Cannot find jshint on $PATH' unless ok
    end
  end

  task :check => 'jshint:require' do
    project_root = File.expand_path('../../', File.dirname(__FILE__))
    config_file = File.join(project_root, 'config', 'jshint.json')
    js_root_dir = File.join(project_root, 'public', 'javascripts')

    files = Rake::FileList.new
    files.include File.join(js_root_dir, '**', '*.js')
    files.exclude File.join(js_root_dir, 'vendor', '**', '*.js')

    sh "jshint #{files.join(' ')} --config #{config_file}" do |ok, res|
      fail 'JSHint found errors.' unless ok
    end
  end
end

desc 'Run JSHint checks against Javascript source'
task :jshint => 'jshint:check'
