require 'json'
require 'csv'
require 'selenium-webdriver'
require "google_drive"

class DataScraper
	PR_TIMES_URL = 'https://prtimes.jp'
  PR_TIMES_LOGIN_URL = 'https://prtimes.jp/main/html/medialogin'
	URL_CATEGORIES = [
		'sports',
		# 'technology',
		# 'mobile',
		# 'app',
		# 'entertainment',
		# 'beauty',
		# 'fashion',
		# 'lifestyle',
		# 'business',
		# 'gourmet',
	]

	## コンストラクタ
	def initialize()
		driver = Selenium::WebDriver.for :chrome
		@driver = driver
	end

	## ログイン
	def login
		@driver.get(PR_TIMES_LOGIN_URL)
    sleep(rand(1..3))
    usernameField = @driver.find_elements(:class_name, 'form__input')[0]
    usernameField.send_keys(ENV['PR_TIMES_ID'])
    sleep(rand(1..3))
    passwordField = @driver.find_elements(:class_name, 'form__input')[1]
    passwordField.send_keys(ENV['PR_TIMES_PASSWORD'])
    sleep(rand(1..3))
    loginButton = @driver.find_element(:tag_name, 'button')
    loginButton.click
    sleep(rand(1..3))
	end

	## 1カテゴリごとに1日分の記事URLを取得
	def get_article_url(url)
		@driver.get(url)
    sleep(rand(1..3))

		article_links = []
		j = 0
		catch(:escape_get_articles) do
			while true do
				@driver.find_element(:class_name, 'list-article__more-link').click
				sleep(rand(2..4))
				target_elements = @driver.find_elements(:class_name, 'list-article__link')[j..j+39]
				target_elements.each_with_index do |el, i|
					time = el.find_element(:tag_name, 'time').attribute('datetime')
					## 昨日の同じ時刻よりも前でない場合、ループを抜ける
					throw(:escape_get_articles) if DateTime.now.prev_day > DateTime.parse(time)
					article_links.push(el.attribute('href'))
				end
				j += 40
				sleep(rand(1..3))
			end
		end
		return article_links
	end

	## 全カテゴリの1日分の記事URLを取得
	def get_article_urls
		@target_article_links = []
		URL_CATEGORIES.each do |category|
			url = PR_TIMES_URL + '/' + category + '/'
			article_urls = get_article_url(url)
			articles_hash = { category: category, article_urls: article_urls }
			@target_article_links.push(articles_hash)
		end
	end

	def execute_scraping(spread_sheet_handler)
		@target_article_links.each do |target_article_link|
			category = target_article_link[:category]
			article_urls = target_article_link[:article_urls]
			article_urls.each do |link|
				sleep(rand(1..3))
				@driver.get(link) ## 各記事に遷移
				sleep(rand(1..3))
				target_element_text = ''
				convert_elements = []
				begin
					target_element_text = @driver.find_element(:id, 'media-only-information').text
					convert_elements = target_element_text.split("\n").compact_blank ## 配列形式に直す
				rescue => exception
					p exception
					p link
					next
				end
				if convert_elements.size < 1
					puts 'next'
					puts convert_elements
					next
				end

				company = Company.new(pritimes_url: link)

				## 会社名 右上のサイドバーカラ取得
				company.company_name = @driver.find_element(:xpath, '//*[@id="sidebar"]/aside[1]/div[1]').text

				## 電話番号
				right_content_list = @driver.find_elements(:xpath, '//*[@id="containerInformationCompany"]/li')
				right_content_list.each do |content|
					text = content.find_elements(:tag_name, 'span')[1].text
					if text.match(Company::VALID_PHONE_NUMBER_REGEX)
						company.tel = text
						break
					end
				end

				email_pattern = /\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b/
				matches = target_element_text.match(email_pattern)
				email = matches[0] if matches

				convert_elements.each do |element|
					## 上の正規表現でメールアドレスが取得できなければ、文字列を一つずつ比較していって探す
					if !email
						if element.include?('【') ## 【が入ってるのはいらない
							next
						end
						# メールアドレス
						email = Company::check_email(element)
					end

					## 正規表現もしくは文字列の比較で取得できれば代入
					if email && company.email.blank?
						company.email = email
						next
					end

					## 担当者
					charge_employee = Company::check_charge_employee(element)
					if charge_employee && company.charge_employee.blank?
						company.charge_employee = charge_employee
						next
					end

					## メールアドレスも担当者も取得したらループを抜ける
					if email && charge_employee
						break
					end
				end

				## 会社名・メールアドレスがなければ保存しない
				if company.company_name.blank? || company.email.blank?
					next
				end

				## 既に同一の会社名・メールアドレスのデータがあれば保存しない
				if Company.find_by(company_name: company.company_name, email: company.email).present?
					next
				end

				## カテゴリ
				company.category = Company::CONST_CATEGORY[category.to_sym]

				## スプレッドシートに保存
				spread_sheet_handler.insert_sheet(company)

				## DBに保存
				company.save

				## last_rowを+1する
				spread_sheet_handler.increment_last_row
			end
		end
	end
end