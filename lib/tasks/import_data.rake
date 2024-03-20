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

	desc '電話番号をスプレッドシートに書き込む'
	task insert_tel_number: :environment do
		## シートの取得
		session = GoogleDrive::Session.from_config(".config.json")
		@sheet = session.spreadsheet_by_key("1LNGQQ1zbO7Iph8QiTkw1UdYVmCxpusAWopdbLbr8FzU").worksheets[1]
		puts @sheet.title

		def insert_sheet(company, last_row)
			## 最終行に追加
			@sheet[last_row, 1] = company["name"]
			@sheet[last_row, 2] = company["pritimes_url"]
			@sheet[last_row, 3] = company["email"]
			@sheet[last_row, 4] = company["tel"]
			@sheet[last_row, 5] = company["charge_employee"]
			@sheet[last_row, 6] = company["category"]
			@sheet[last_row, 7] = company["created_at"]
			@sheet.save
		end

		## データの取得
		json_data = File.read('output-company-data.json')
    @target_data = JSON.parse(json_data)
		last_row = 2
		@target_data.each_with_index do |company, i|
			target_row = last_row + i
			insert_sheet(JSON.parse(company), target_row)
			if target_row % 50 == 0
				puts "sleep start #{target_row}"
				puts "sleep end"
			end
		end
	end
end
