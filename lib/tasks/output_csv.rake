require 'csv'
require 'json'
require "google_drive"

namespace :output_csv do
	desc 'DBのデータをCSVファイルにエクスポート'
	task data: :environment do
		today = Time.new.strftime("%Y-%m-%d %H:%M:%S")
		CSV.open("output-company-data #{today}.csv","w", :encoding => "utf-8") do |csv|
			csv << ["会社名", "prtimesのURL", "メールアドレス", "担当者", "カテゴリ", "日時", "連絡禁止", "初回アポ済み"]

			Company.all.each do |company|
				csv << [
					company.company_name,
					company.pritimes_url,
					company.email,
					company.charge_employee,
					company.category,
					company.created_at.strftime("%Y-%m-%d %H:%M:%S"),
					company.is_blocked_company ? "○" : "",
					company.is_client ? "○" : ""
				]
			end
		end
	end

	desc 'スプレッドシートのデータをCSVファイルにエクスポート'
	task sheet: :environment do
		today = Time.new.strftime("%Y-%m-%d %H:%M:%S")
		CSV.open("output-company-data #{today}.csv","w", :encoding => "utf-8") do |csv|
			csv << ["会社名", "prtimesのURL", "メールアドレス", "担当者", "カテゴリ", "日時", "連絡禁止", "初回アポ済み"]

			session = GoogleDrive::Session.from_config(".config.json")
			sheet = session.spreadsheet_by_key("1LNGQQ1zbO7Iph8QiTkw1UdYVmCxpusAWopdbLbr8FzU").worksheets[0]

			i = 2
			while true do
				if sheet[i, 1].blank?
					break
				end
				csv << [
					sheet[i, 1],
					sheet[i, 2],
					sheet[i, 3],
					sheet[i, 4],
					sheet[i, 5],
					sheet[i, 6],
					sheet[i, 7].blank? ? "" : "○",
					sheet[i, 8].blank? ? "" : "○",
				]
				i += 1
			end
		end
	end
end
