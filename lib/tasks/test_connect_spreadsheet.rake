namespace :test_connect_spreadsheet do
	desc 'スプレッドシートとの接続テストタスク'
	task test: :environment do
		# session = GoogleDrive::Session.from_config(".config.json")
		# sheet = session.spreadsheet_by_key("1LNGQQ1zbO7Iph8QiTkw1UdYVmCxpusAWopdbLbr8FzU").worksheets[0]
		# puts session.spreadsheet_by_key("1LNGQQ1zbO7Iph8QiTkw1UdYVmCxpusAWopdbLbr8FzU").worksheets
		puts "connect"

		# 書き込み
		# sheet[1650, 1] = "From API"
		# sheet.save
	end
end
