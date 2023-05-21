namespace :test_connect_spreadsheet do
	desc 'スプレッドシートとの接続テストタスク'
	task test: :environment do

		session = GoogleDrive::Session.from_config(".config.json")
		sheet = session.spreadsheet_by_key("1LNGQQ1zbO7Iph8QiTkw1UdYVmCxpusAWopdbLbr8FzU").worksheets[0]

		# 書き込み
		# sheet[1,1] = "From API"
		# sheet.save

		## 読み取り
		i = 2
		while true do
			data = sheet[i, 1]
			if data.empty?
				break
			end
			puts data
			i += 1
		end
		puts i
	end
end
