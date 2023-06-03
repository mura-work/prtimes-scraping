require 'json'
require 'csv'
require 'selenium-webdriver'
require "google_drive"

namespace :scraping_latest_data do
	desc '直近1日の記事をスクレイピングする'
	task sheet: :environment do
		data_scraper = DataScraper.new
		data_scraper.login
		data_scraper.get_article_urls
		spread_sheet_handler = SpreadSheetHandler.new
		spread_sheet_handler.set_last_row
		data_scraper.execute_scraping(spread_sheet_handler)
	end
end
