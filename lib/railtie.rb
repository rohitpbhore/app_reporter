module Reporter
  class Railtie < Rails::Railtie
  	rake_tasks do
    	spec = Gem::Specification.find_by_name 'reporter'
			load "#{spec.gem_dir}/lib/tasks/reporter.rake"
  	end
  end
end