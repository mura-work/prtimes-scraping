require 'json'
require 'csv'
require 'selenium-webdriver'
require "google_drive"

class DataScraper
	PR_TIMES_URL = 'https://prtimes.jp'
  PR_TIMES_LOGIN_URL = 'https://prtimes.jp/main/html/medialogin'
	URL_CATEGORIES = [
		'technology',
		'mobile',
		'app',
		'entertainment',
		'beauty',
		'fashion',
		'lifestyle',
		'business',
		'gourmet',
		'sports',
	]

	## コンストラクタ
	def initialize()
		options = Selenium::WebDriver::Chrome::Options.new

		# 下記オプションをつけないと Docker 上で動かない。
		options.add_argument('--headless')
		options.add_argument('--no-sandbox')
		options.add_argument('--disable-dev-shm-usage')
		driver = Selenium::WebDriver.for :chrome, options: options
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
			begin
				category = target_article_link[:category]
				article_urls = target_article_link[:article_urls]
				article_urls.each do |link|
					sleep(rand(1..3))
					@driver.get(link) ## 各記事に遷移
					sleep(rand(1..3))
					target_text = ''
					begin
						article_element = @driver.find_element(:css, '#press-release-body + *')
						if !article_element
							next
						end
						target_text = article_element.text
					rescue => exception
						p exception
						p link
						next
					end

					if !target_text
						puts `要素が取得できませんでした：#{link}`
						next
					end

					company = Company.new(pritimes_url: link)

					## 会社名 articleタグの一番最初のpタグから取得
					## DOM構造が変わったら取れなくなるので微妙ではある
					company.company_name = @driver.find_element(:css, '#js-heatmap-subject-area a p').text

					## 電話番号
					tel = target_text.match(Company::VALID_PHONE_NUMBER_REGEX)
					if tel
						company.tel = tel[0]
					end

					## メールアドレスの取得
					### 特定のメールアドレスの末尾であれば保存しない
					## emailが取得できなかったor除外するメールアドレスと一致していたらデータを保存せず次の記事に移動する
					email = target_text.match(Company::VALID_EMAIL_REGEX)
					if !email || Company::EMAIL_END_TARGET_EXCLUSION.find {|target| email[0].end_with?(target) }
						next
					end
					company.email = email[0]

					## 担当者
					charge_employee_match = target_text.match(Company::VALID_CHARGE_EMPLOYEE_TARGET)
					charge_employee = charge_employee_match && charge_employee_match[1].strip
					if charge_employee
						company.charge_employee = charge_employee
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
			rescue => exception
				p exception
				next
			end
		end
	end
end