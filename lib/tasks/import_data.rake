require "google_drive"
require 'json'
require 'csv'

namespace :import_data do
	desc 'CSVファイルからインポート'
	task csv: :environment do
		i = 0
		CSV.foreach("output-company-data.csv") do |row|
			if i == 0
				i += 1
				next ## 1行目はヘッダー部分なので不要
			end
			company = Company.new
			company.company_name = row[0]
			company.charge_employee = row[1]
			company.tel = row[2]
			company.email = row[3]
			company.category = row[4]
			company.pritimes_url = row[5]
			company.is_blocked_company = !!row[6]
			company.is_client = !!row[7]
			company.save
			i += 1
			break
		end
	end

	desc 'スプレッドシートからインポート'
	task sheet: :environment do
		puts 'sheet'
	end
end
