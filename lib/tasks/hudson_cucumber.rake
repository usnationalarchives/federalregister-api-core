namespace :hudson do
  begin
    require 'cucumber'
    require 'cucumber/rake/task'

    def report_path
      "hudson/reports/features/"
    end

    Cucumber::Rake::Task.new({:cucumber  => [:report_setup, 'db:test:prepare']}) do |t|
      t.cucumber_opts = %{--profile default  --format junit --out #{report_path}}
    end
  rescue LoadError
  end

  task :report_setup do
    rm_rf report_path
    mkdir_p report_path
  end
end