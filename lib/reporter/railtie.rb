module Reporter
  class Railtie < Rails::Railtie
  	rake_tasks do
    	load "./lib/tasks/reporter.rake"
  	end
  end
end