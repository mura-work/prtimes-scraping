require "google_drive"
require 'json'
require 'csv'

namespace :import_data do
	desc 'CSVファイルからインポート'
	task csv: :environment do
		i = 0
		CSV.foreach("output-company-data.origin.csv") do |row|
			if i == 0
				i += 1
				next ## 1行目はヘッダー部分なので不要
			end
			company = Company.new
			company.company_name = row[0]
			company.pritimes_url = row[1]
			company.email = row[2]
			company.charge_employee = row[3]
			company.category = row[4]
			company.insert_date_time = row[5]
			company.is_blocked_company = row[6].present?
			company.is_client = row[7].present?
			company.save
			i += 1
		end
	end

	desc 'スプレッドシートからインポート'
	task sheet: :environment do
		puts 'sheet'
	end
end
