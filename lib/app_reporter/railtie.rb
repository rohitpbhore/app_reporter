module AppReporter
  class Railtie < Rails::Railtie
  	rake_tasks do
    	spec = Gem::Specification.find_by_name 'app_reporter'
			load "#{spec.gem_dir}/lib/tasks/app_reporter.rake"
  	end
  end
end