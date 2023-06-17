require 'csv'
require 'json'

namespace :output_csv do
	desc 'CSVファイルにエクスポート'
	task export: :environment do
		today = Time.new.strftime("%Y-%m-%d %H:%M:%S")
		CSV.open("output-company-data #{today}.csv","w", :encoding => "utf-8") do |csv|
			csv << ["会社名", "担当者", "電話番号", "メールアドレス", "カテゴリ", "prtimesのURL", "日時", "連絡禁止", "初回アポ済み"]

			Company.all.each do |company|
				csv << [
					company.company_name,
					company.charge_employee,
					company.tel,
					company.email,
					company.category,
					company.pritimes_url,
					company.created_at.strftime("%Y-%m-%d %H:%M:%S"),
					company.is_blocked_company ? "○" : "",
					company.is_client ? "○" : ""
				]
			end
		end
	end
end
