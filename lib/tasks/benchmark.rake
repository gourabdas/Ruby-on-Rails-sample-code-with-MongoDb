namespace :benchmark do
  desc "Importing Asset from Beekman_Master_Data.xlsx"
  task :import_asset_list => :environment do
    begin
      s = Excelx.new(Rails.configuration.benchmark_assets_path)
      s.default_sheet = s.sheets[154]
      2.upto(152) do |line|        
        name = s.cell(line,'C').to_s
        asset = Asset.create(:name => name,:asset_type=> s.cell(line,'B'),:description  => s.cell(line,'D'))
        puts"|->=#{asset.name}"
      end
    rescue Exception => e
      puts"------------------------------->"
      puts "Error: #{e.message}"
    end
    puts "Importing completed"
  end

  desc "Importing Markets from Beekman_Master_Data.xlsx"
  task :import_markets => :environment do
    begin
      s = Excelx.new(Rails.configuration.benchmark_assets_path)
      s.default_sheet = s.sheets[157]
      puts "Total Markets: #{Market.count}"
      2.upto(28) do |line|
        country_name = s.cell(line,'A').to_s.strip
        market = Market.where(:name=>country_name)
        unless market.present?
          if country_name.present?
            country = Country.where(:printable_name => country_name).first
            if country.present?
              country.markets.create(:name => country_name)
            else
              case country_name
              when 'Russia'
                country = Country.where(:iso => 'RU').first
              when 'UAE'
                country = Country.where(:iso => 'AE').first
              when 'UK (London)'
                country = Country.where(:iso => 'GB').first
              when 'US (NY)'
                country = Country.where(:iso => 'US').first
              end
              country.markets.create(:name => country_name) if
              country.present?
            end
            puts "country: #{country_name}"
          end
        end
      end
    rescue Exception => e
      puts"------------------------------->"
      puts "ERROR: #{e.message}"
    end
    puts "Importing completed"
  end

  desc "Importing Department from Beekman_Master_Data.xlsx"
  task :import_departments => :environment do
    begin
      s = Excelx.new(Rails.configuration.benchmark_assets_path)
      s.default_sheet = s.sheets[2]
      2.upto(580) do |line|
        d_name = s.cell(line,'D').to_s
        department = Department.where(:title => d_name).first
        unless (department.present? || s.cell(line,'D').to_s == "N/A" || line == 376 )
          dept = Department.create(:title  => s.cell(line,'D'))
          puts"department_title ==> #{dept.title}"
        end
      end
    rescue Exception => e
      puts"------------------------------->"
      puts "ERROR: #{e.message}"
    end
    puts "Importing completed"
  end

  desc "Importing job titles from Beekman_Master_Data.xlsx file"
  task :import_job_titles => :environment do
    puts "Importing started ..."
    begin
      s = Excelx.new(Rails.configuration.benchmark_assets_path)
      s.default_sheet = s.sheets[2]
      92.upto(375) do |line|
        title = s.cell(line,'F').strip
        unless JobTitle.where(:title => title).first.present?
          job_title = JobTitle.create(:title => title)
          puts "|-> #{job_title.title}"
          puts "---------------------------------------------------------------"
        end
      end
      #      puts "Total: #{JobTitle.all.count}"
    rescue Exception => e
      puts"------------------------------->"
      puts "ERROR: #{e.message}"
    end
    puts "Importing completed"
  end

  desc "Importing Metrics from Beekman_Master_Data.xlsx file"
  task :import_metrics => :environment do
    begin
      s = Excelx.new(Rails.configuration.benchmark_assets_path)
      s.default_sheet = s.sheets[2]
      2.upto(580) do |line|
        title = s.cell(line,'C').to_s if s.cell(line,'C').present?
        metric = Metric.where(:title => title).first
        unless (metric.present? || line == 376)
          metrc= Metric.create(:title  => s.cell(line,'C'),:format => "percentage")
          puts"metric title ==> #{metrc.title}"
        end
      end
    rescue Exception => e
      puts"------------------------------->"
      puts "ERROR: #{e.message}"      
    end
  end

  desc "Importing Disciplines from Beekman_Master_Data.xlsx file"
  task :import_disciplines => :environment do
    begin
      s = Excelx.new(Rails.configuration.benchmark_assets_path)
      s.default_sheet = s.sheets[2]
      2.upto(91) do |line|
        title = s.cell(line,'B').to_s
        discipline = Discipline.where(:name => title )
        unless (discipline.present? || line == 376)
          discp=Discipline.create(:name => title)
        end
      end
    rescue Exception => e
      puts"------------------------------->"
      puts "ERROR: #{e.message}"
    end
  end  

  desc "Importing Benchmark Metrics from benchmark_matrics.xlsx"
  task :import_benchmark_metrics => :environment do
    begin
      s = Excelx.new(Rails.configuration.benchmark_matrics_path)
      s.default_sheet = s.sheets[0]
      disciplines = Discipline.all
      metrics = Metric.all
      markets = Market.all
      index = 0
      start_row = 2
      end_row = metrics.length - 1
      disciplines.each do |discipline|
        start_row.upto(end_row) do |line|
          metric_name = Metric.where(:title => s.cell(line,'C')).first
          discipline_name = Discipline.where(:name => s.cell(line,'B')).first
          column_no = 9
          markets.each do |market|
            bnchm = BenchmarkMetric.create!(
              :discipline_id  => discipline_name.id,
              :discipline_name => discipline_name.name,
              :metric_id => metric_name.id,
              :metric_title => metric_name.title,
              :market_id => market.id,
              :market_name => market.name,
              :tier => s.cell(line,'E'),
              :value => s.cell(line,column_no)
            )            
            column_no += 1
            puts"value===================================================>#{s.cell(line,column_no)}"
            puts"Disciplines=====================================> #{discipline.name}"
            puts"metric==============================>#{metrics[index].title}"
            puts"market name ==========>#{market.name}"
            puts"Bench marke value==> #{bnchm.value}"
          end
          index += 1
        end
        start_row = end_row +1
        end_row   += metrics.length - 2
        
        index = 0
        
      end

    rescue Exception => e
      puts "--------------------------->"
      puts "ERROR: #{e.message}"
    end
    puts "Importing completed"
  end

  desc "Before proceeding Import Indirect Payroll Total raking process make sure that above raking process (import_benchmark_metrics) must be completed."
  task :import_indirect_payroll_total => :environment do
    puts "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
    puts "Process started on #{Time.now()}"
    begin
      metrics = Metric.where(:title.in => ["Indirect Payroll - From Direct Staff", "Indirect Payroll - From Indirect Staff"]).collect {|m| m.id}
      metric = Metric.where(:title => "Indirect Payroll - Total").first()
      puts "|-> #{metric.title}"
      BenchmarkMetric.where(:metric_id => metric.id).each do |bm|
        puts "  |-> #{Discipline.find(bm.discipline_id).name}"
        puts "  |-> #{Market.find(bm.market_id).name}"
        indirect_payroll_total = BenchmarkMetric.where(:discipline_id => bm.discipline_id, :market_id => bm.market_id, :metric_id.in => metrics).collect {|m| m.value.to_f}.reduce(:+)
        puts "  |-> #{indirect_payroll_total}"
        bm.update_attributes(:value => indirect_payroll_total)
        puts "-----------------------------"
      end
    rescue Exception => e
      puts "ERROR: #{e.message}"
    end
    puts "Process completed on #{Time.now()}"
    puts "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
  end

  desc "Imports Overhead Rate from Benchmark Data (Before importing Indirect Payroll Total must be imported)."
  task :import_overhead_rate => :environment do
    puts "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
    puts "Process started on #{Time.now()}"
    begin
      metrics = Metric.where(:title.in => ["Indirect Payroll - Total", "Payroll Related Expenses", "Employee Incentives", "Corporate Expenses", "Parent/Holding Company Fees", "Professional Fees", "Space & Facilities"]).collect {|m| m.id}
      metric = Metric.where(:title => "Overhead Rate").first()
      puts "|-> #{metric.title}"
      BenchmarkMetric.where(:metric_id => metric.id).each do |bm|
        puts "  |-> #{bm.discipline_name}"
        puts "  |-> #{bm.market_name}"
        overhead_rate = BenchmarkMetric.where(:discipline_id => bm.discipline_id, :market_id => bm.market_id, :metric_id.in => metrics).collect {|m| m.value.to_f}.reduce(:+)
        puts "  |-> #{overhead_rate}"
        bm.update_attributes(:value => overhead_rate)
        puts "-----------------------------"
      end
    rescue Exception => e
      puts "ERROR: #{e.message}"
    end
    puts "Process completed on #{Time.now()}"
    puts "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
  end

  desc "Imports Multiplier from Benchmark Data (Before importing multiplier  Overhead Rate must be imported)."
  task :import_multiplier => :environment do
    puts "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
    puts "Process started on #{Time.now()}"
    begin      
      orate_metric = Metric.where(:title => "Overhead Rate").first()
      pm_metric = Metric.where(:title => "Profit Margin").first()
      m_metric = Metric.where(:title => "Multiplier").first()
      puts "|-> #{orate_metric.title}"
      puts "|-> #{pm_metric.title}"
      puts "|-> #{m_metric.title}"
      BenchmarkMetric.where(:metric_id => m_metric.id).each do |bm|
        puts "  |-> #{bm.discipline_name}"
        puts "  |-> #{bm.market_name}"
        overhead_rate = BenchmarkMetric.where(:discipline_id => bm.discipline_id, :market_id => bm.market_id, :metric_id => orate_metric.id).first
        profit_margin = BenchmarkMetric.where(:discipline_id => bm.discipline_id, :market_id => bm.market_id, :metric_id => pm_metric.id).first
        puts "  |Overhead Rate-> #{overhead_rate.value}"
        puts "  |Profit Margin-> #{profit_margin.value}"
        multiplier = (1+overhead_rate.value.to_f)/(1-profit_margin.value.to_f)
        puts "===> Multiplier #{multiplier}"
        bm.update_attributes!(:value => multiplier)
        puts "-----------------------------"
      end
    rescue Exception => e
      puts "ERROR: #{e.message}"
    end
    puts "Process completed on #{Time.now()}"
    puts "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
  end

  
  desc "Importing Annual Salaries from Benchmark File (Before importing salaries Benchmark Metrics must be imported)."
  task :import_salaries => :environment do
    puts "Importing started ..."
    begin
      s = Excelx.new(Rails.configuration.benchmark_assets_path)
      s.default_sheet = s.sheets[2]
      countries = s.row(1)[8..34]
      92.upto(580) do |line|
        if s.cell(line,'B').present?
          discipline = Discipline.where(:name => s.cell(line,'B').strip).first
          metric = Metric.where(:title => s.cell(line,'C').strip).first
          department = Department.where(:title => s.cell(line,'D').strip).first
          job_title = JobTitle.where(:title => s.cell(line,'F').strip).first
          tier = s.cell(line,'E')
          description = s.cell(line,'G')
          experience = s.cell(line,'H')
          puts "|-> #{discipline.name}"
          puts "|-> #{metric.title}"
          puts "|-> #{department.title}"
          puts "|-> #{job_title.title}"
          countries.each_with_index do |country, index|
            cell_index = index+9
            market = Market.where(:name => country).first
            a_rate  = 0
            a_rate  = s.cell(line, cell_index) if metric.title == "Direct Base Salary"
            puts "  |-> #{market.name}"
            puts "  |-> Annual Rate : #{a_rate}"
            bsal = BenchmarkSalary.where(:discipline_id => discipline.id, :department_id => department.id, :job_title_id => job_title.id, :market_id => market.id, :tier => tier, :years_of_exp => experience).first
            unless bsal.present?
              m_value = BenchmarkMetric.where(:market_id => market.id, :discipline_id  => discipline.id, :metric_title => "Multiplier").first
              h_value = BenchmarkMetric.where(:market_id => market.id, :discipline_id  => discipline.id, :metric_title => "Hours/FTE").first            
              h_rate = (a_rate*m_value.value)/h_value.value
              puts "  |-> Hourly Rate : #{h_rate}"
              BenchmarkSalary.create!(
                :discipline_id  => discipline.id,
                :discipline_name => discipline.name,
                :department_id  => department.id,
                :department_title => department.title,
                :job_title_id   => job_title.id,
                :job_title_name => job_title.title,
                :market_id      => market.id,
                :market_name => market.name,
                :tier           => tier,
                :description    => description,
                :years_of_exp   => experience,
                :annual_rate    => a_rate,
                :hourly_rate    => h_rate
              )    
            end               
          end
          puts "---------------------------------------------------------------"
        end
      end
    rescue Exception => e
      puts "ERROR: #{e.message}"
    end
    puts "Importing completed"
  end

  desc "Importing benchmark asset hours from xlsx file"
  task :import_hours => :environment do
    begin
      s = Excelx.new(Rails.configuration.benchmark_assets_path)
      3.upto(153) do |index|
        s.default_sheet = s.sheets[index]
        name = s.cell(5,'A')
        asset = Asset.where(:name => name).first()
        puts "|-> #{asset.name}"
        dtitle = nil
        9.upto(s.last_row) do |line|
          jtitle = s.cell(line,'C')
          if jtitle.present?
            dtitle = s.cell(line,'A') if s.cell(line,'A').present?
            department = Department.where(:title => dtitle).first() if dtitle.present?
            jtitle = "Account Executive" if jtitle == "Account Executive/Manager/Associate"
            job_title = JobTitle.where(:title => jtitle).first()
            puts "  |-> #{department.title}" if s.cell(line,'A').present?
            puts "    |-> #{job_title.title}"
            disc = get_discipline_by_dept_title(department.title)
            raise "Can't find any discipline by department." if !disc.present?
            param = {
              :gold_hours => s.cell(line,'E'), :silver_hours => s.cell(line,'F'),
              :bronze_hours => s.cell(line,'G'),
              :job_title_id => job_title.id,
              :department_id => department.id,
              :asset_name => asset.name,
              :department_title => department.title,
              :job_title_name => job_title.title
            }
            param.merge!(disc)
            asset_hour = asset.asset_hours.where(:job_title_id => job_title.id, :department_id => department.id).first()
            if asset_hour.present?
              asset_hour.update_attributes!(param)
              puts "    |-> Updating ..."
            else
              asset.asset_hours.create!(param)
              puts "    |-> Creating ..."
            end
            puts "    |-> ---------------"
          end
        end
      end
    rescue Exception => e
      puts "ERROR: #{e.message}"
      puts e.backtrace
    end
    puts "Importing completed"
  end

  desc "Importing Asset Rates from Benchmark Date (Before importing this  Asset hours must be imported)."
  task :import_asset_rates => :environment do
    begin
      s = Excelx.new(Rails.configuration.benchmark_assets_path)
      s.default_sheet = s.sheets[155]
      markets = Market.all
      asset_hours = AssetHour.all
      i = 0; asset_rate_not_imported = []
      markets.each do |markt|
        puts "|-> #{markt.name}"
        asset_hours.each do |asst|
          b_salary = BenchmarkSalary.where(:market_id => markt.id, :discipline_id  => asst.discipline_id, :department_id  => asst.department_id, :job_title_id => asst.job_title_id).first
          if b_salary.present?
            puts "  |-> #{asst.asset_name}"
            puts "  |-> #{asst.discipline_name}"
            puts "  |-> #{asst.department_title}"
            puts "  |-> #{asst.job_title_name}"
            g_rate = asst.gold_hours.to_f*b_salary.hourly_rate.to_f
            s_rate = asst.silver_hours.to_f*b_salary.hourly_rate.to_f
            b_rate = asst.bronze_hours.to_f*b_salary.hourly_rate.to_f
            puts "  |-> Gold: #{g_rate}"
            puts "  |-> Silver: #{s_rate}"
            puts "  |-> Bronze: #{b_rate}"
            AssetRate.create!(
              :gold_cost  => g_rate,
              :silver_cost => s_rate,
              :bronze_cost  => b_rate,
              :asset_id  => asst.asset_id,
              :market_id => markt.id,
              :discipline_id => asst.discipline_id,
              :department_id => asst.department_id,
              :job_title_id => asst.job_title_id,
              :market_name => markt.name,
              :asset_name => asst.asset_name,
              :discipline_name => asst.discipline_name,
              :department_title => asst.department_title,
              :job_title_name => asst.job_title_name
            )
            puts "  |-> -------------------------------------------"
          else
            asset_rate_not_imported << {:asset => asst.asset_name, :discipline => asst.discipline_name, :department => asst.department_title, :job_title => asst.job_title_name, :market => markt.name}
            i+=1
          end
        end
      end
      puts "Total Rate not found #{i}"
      puts asset_rate_not_imported
    rescue Exception => e
      puts "--------------------------->"
      puts "ERROR: #{e.message}"
    end
  end

  desc "Checking Overhead Rate."
  task :checking_overhead_rate => :environment do
    puts "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
    puts "Process started on #{Time.now()}"
    begin
      metric = Metric.where(:title => "Overhead Rate").first()
      puts "|-> #{metric.title}"
      BenchmarkMetric.where(:metric_id => metric.id, :value.in => ["", nil]).each do |bm|
        puts "  |-> #{Discipline.find(bm.discipline_id).name}"
        puts "  |-> #{Market.find(bm.market_id).name}"
        puts "  |-> #{bm.value}"
        puts "-----------------------------"
      end
    rescue Exception => e
      puts "ERROR: #{e.message}"
    end
    puts "Process completed on #{Time.now()}"
    puts "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
  end

  def get_discipline_by_dept_title(dept_title)
    disp = {}
    case dept_title
    when "Account Management", "Creative", "Strategic Planning", "Production"
      dis = Discipline.where(:name => "Advertising").first
      if dis.present?
        puts "    |-> #{dis.name}"
        disp.merge!(:discipline_id => dis.id, :discipline_name => dis.name)
      end
    when "Digital Account Management", "Digital Creative", "Digital Production", "Digital Strategic Planning"
      dis = Discipline.where(:name => "Digital").first
      if dis.present?
        puts "    |-> #{dis.name}"
        disp.merge!(:discipline_id => dis.id, :discipline_name => dis.name)
      end
    when "Public Relations"
      dis = Discipline.where(:name => "Public Relations").first
      if dis.present?
        puts "    |-> #{dis.name}"
        disp.merge!(:discipline_id => dis.id, :discipline_name => dis.name)
      end
    end
    disp
  end

  desc "Checking Benchmar Salary Data"
  task :test_salaries => :environment do
    puts "Importing started ..."
    begin
      s = Excelx.new(Rails.configuration.benchmark_assets_path)
      s.default_sheet = s.sheets[2]
      countries = s.row(1)[8..34]
      d_count = 0
      92.upto(580) do |line|
        if s.cell(line,'B').present?         
          metric = Metric.where(:title => s.cell(line,'C').strip).first         
          tier = s.cell(line,'E')
          description = s.cell(line,'G')
          experience = s.cell(line,'H')
         
          countries.each_with_index do |country, index|
            cell_index = index+9
            market = Market.where(:name => country).first
            a_rate  = s.cell(line, cell_index)                    
            if metric.title == "Hourly Rate"
              d_count = d_count + 1
            end
          end
          puts "========>  #{d_count}"
        end
      end
    rescue Exception => e
      puts "ERROR: #{e.message}"
    end
    puts "Process completed on #{Time.now()}"
    puts "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
  end

  desc "update asset hours table"
  task :update_asset_hours => :environment do
    begin
      arate_not_found = 0
      bs_not_found = 0
      bs_found = 0
      arate_found = 0
      asset_hours = AssetHour.where(:department_title => "Public Relations", :job_title_name => "Assistant Account Executive/Manager/Associate").limit(100)
      job_title = JobTitle.where(:title => "Account Executive").first
      markets = Market.all
      
      asset_hours.each do |ah|
        puts "|-> #{ah.asset_name}"
        markets.each do |markt|
          puts " |-> #{markt.name}"
          b_salary = BenchmarkSalary.where(:market_id => markt.id, :discipline_id  => ah.discipline_id, :department_id  => ah.department_id, :job_title_id => job_title.id).first
          if b_salary.present?
            bs_found += 1
            puts "  |-> BS Discipline: #{b_salary.discipline_name}"
            puts "  |-> BS Department: #{b_salary.department_title}"
            puts "  |-> BS Job Title: #{b_salary.job_title_name}"
            
            g_rate = ah.gold_hours.to_f*b_salary.hourly_rate.to_f
            s_rate = ah.silver_hours.to_f*b_salary.hourly_rate.to_f
            b_rate = ah.bronze_hours.to_f*b_salary.hourly_rate.to_f
            
            asset_rate = AssetRate.where(:asset_id => ah.asset_id, :market_id => markt.id, :discipline_id => ah.discipline_id, :department_id => ah.department_id, :job_title_id => ah.job_title_id).first
            if asset_rate.present?
              arate_found += 1
              puts "  |-> AR Discipline: #{asset_rate.discipline_name}"
              puts "  |-> AR Department: #{asset_rate.department_title}"
              puts "  |-> AR Job Title: #{asset_rate.job_title_name}"
              asset_rate.update_attributes!(
                :gold_cost => g_rate,
                :silver_cost => s_rate,
                :bronze_cost => b_rate,
                :job_title_id => job_title.id,
                :job_title_name => "Account Executive"
              )
            else
              arate_not_found += 1
              puts "  |-> Asset Rate Not Found"
            end
          else
            bs_not_found += 1
            puts "  |-> Benchmark salary Not Found"
          end
        end
        ah.update_attributes!(:job_title_name => "Account Executive", :job_title_id => job_title.id)
      end if asset_hours.present?
      
      puts "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
      puts "Total Asset Hours: #{asset_hours.size}"
      puts "Total BS Found: #{bs_found}"
      puts "Total BS Not Found: #{bs_not_found}"
      puts "Total Asset Rate Modified: #{arate_found}"
      puts "Total Asset Rate Not Found: #{arate_not_found}"
      puts "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
    rescue Exception => e
      puts "ERROR: #{e.message}"
      puts e.backtrace
    end
    puts "Importing completed"
  end
end
