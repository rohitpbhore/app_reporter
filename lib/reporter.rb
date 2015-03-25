require "app_reporter/version"
require 'app_reporter/railtie' if defined?(Rails)

module AppReporter
  def brakeman_report
  	# Breakman source file
		file = File.read("#{Rails.root}/report.json")
		data_hash = JSON.parse(file)

		# collect information related to the application
		@breakman_info = {}
		@breakman_info['security_warnings'] = data_hash['scan_info']['security_warnings']
	  @breakman_info['errors'] = data_hash['errors']

	  # Create an array of all warnings
	  @brakeman_warnings = []
	  data_hash['warnings'].each do |warning|
	  	hash = {}
	  	hash['warning_type'] = warning['warning_type']
	  	hash['warning_code'] = warning['warning_code']
	  	hash['fingerprint'] = warning['fingerprint']
	  	hash['message'] = warning['message']
	  	hash['file'] = warning['file']
	  	hash['line'] = warning['line']
	  	hash['code'] = warning['code']
	  	hash['render_path'] = warning['render_path']
	  	hash['location'] = warning['location']
	  	hash['user_input'] = warning['user_input']
	  	hash['confidence'] = warning['confidence']
	  	@brakeman_warnings.push(hash)
	  end
	end

	def metric_fu_report
	  # parsing metric_fu report from .yml file
	  @surveys = YAML.load(ERB.new(File.read("#{Rails.root}/tmp/metric_fu/report.yml")).result)
    @matric_fu_info = []

    @surveys.each do |survey|
    	unless survey.blank?
    		p "===== From #{survey[0]} ====="
	      case survey[0]
				when :flog
	      	hash = {}
					# hash['flog'] = "Flog measures code complexity. Total Flog score for all methods: #{survey[1][:total].round(1)}. Average Flog score for all methods: #{survey[1][:average].round(1)}"
					hash['flog'] = survey[1][:average].round(1)
					@matric_fu_info.push(hash)
				when :stats
					hash = {}
					# hash['stats'] = "Lines of Code/Tests Metric Results. Lines of Code: #{survey[1][:codeLOC]}. Lines of Test: #{survey[1][:testLOC]}. Code to test ratio: #{survey[1][:code_to_test_ratio]}."
					hash['stats'] = survey[1][:code_to_test_ratio]
					hash['codeLOC'] = survey[1][:codeLOC]
					hash['testLOC'] = survey[1][:testLOC]
					@matric_fu_info.push(hash) 
				when :roodi
					hash = {}
					hash['roodi'] = "Roodi parses Ruby code and warns about design issues. #{survey[1][:total].first} and found #{survey[1][:problems].count} problems."
					@matric_fu_info.push(hash)
				when :reek
					hash = {}
					hash['reek'] = "Reek detects common code smells in ruby code. Found #{survey[1][:matches].count} matches."
					@matric_fu_info.push(hash)
				when :cane
					hash = {}
					hash['cane'] = "Cane reports code quality threshold violations. Found total #{survey[1][:violations].count} types of #{survey[1][:total_violations]} violations."
					@matric_fu_info.push(hash)
			  when :flay
			  	hash = {}
			  	hash['flay'] = "Flay analyzes ruby code for structural similarities. Total Score (lower is better): #{survey[1][:total_score]}."
			  	@matric_fu_info.push(hash)
			  when :churn
			  	hash = {}
			  	hash['churn'] = "Source Control Churn Results. Files that change a lot in your project may be bad a sign. Count: #{survey[1][:changes].count}."
			  	@matric_fu_info.push(hash)
			  when :saikuro
			  	hash = {}
			  	hash['saikuro'] = "Saikuro analyzes ruby code for cyclomatic complexity. Analyzed #{survey[1][:files].count} Classes."
			  	@matric_fu_info.push(hash)
			  when :rails_best_practices
			  	hash = {}
			  	hash['rails_best_practices'] = survey[1][:total].first.gsub(/[^\d]/, '').to_i
			  	@matric_fu_info.push(hash)
				when :hotspots
					hash = {}
					hash['hotspots'] = "Meta analysis of metrics to find hotspots in code. Hotspot Results: #{survey[1]['files'].count}."
					@matric_fu_info.push(hash)
				else
				  puts "No Report"
				end
			end
    end
	end

  def generate_final_report
  	spec = Gem::Specification.find_by_name 'app_reporter'
		erb_file = "/#{spec.gem_dir}/lib/app_reporter/templates/summary_report.html.erb"
		html_file = File.basename(erb_file, '.erb') 
		erb_str = File.read(erb_file)

  	@flog_info = @matric_fu_info.select{|d| d.keys.first == 'flog'}
  	@stats_info = @matric_fu_info.select{|d| d.keys.first == 'stats'}
  	@rails_best_practices_info = @matric_fu_info.select{|d| d.keys.first == 'rails_best_practices'}
  	@app_root = Rails.root

	  begin
			renderer = ERB.new(erb_str)
			result = renderer.result()

			File.open(html_file, 'w') do |f|
			  f.write(result)
			end
		rescue StandardError => e
	  	p e.message
	  	p e.backtrace
	  end
	end
end
