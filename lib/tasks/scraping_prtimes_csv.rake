require 'json'
require 'csv'
require 'selenium-webdriver'
require "google_drive"

namespace :scraping_prtimes do
  desc 'prtimesのスクレイピング'
  task csv: :environment do
    driver = Selenium::WebDriver.for :chrome
    PR_TIMES_URL = 'https://prtimes.jp'
    PR_TIMES_LOGIN_URL = 'https://prtimes.jp/main/html/medialogin'

    ## ログイン処理
    driver.get(PR_TIMES_LOGIN_URL)
    sleep(rand(1..3))
    usernameField = driver.find_elements(:class_name, 'form__input')[0]
    usernameField.send_keys(ENV['PR_TIMES_ID'])
    sleep(rand(1..3))
    passwordField = driver.find_elements(:class_name, 'form__input')[1]
    passwordField.send_keys(ENV['PR_TIMES_PASSWORD'])
    sleep(rand(1..3))
    loginButton = driver.find_element(:tag_name, 'button')
    loginButton.click
    sleep(rand(1..3))


    ## スクレイピングする対象のカテゴリを開く
    category = "gourmet"
    target_url = PR_TIMES_URL + "/" + category + "/"
    driver.get(target_url)
    sleep(rand(1..3))


    ## 取得するデータ件数を代入
    get_count = 2000 ## 取得件数
    click_more_button_count = get_count / 40 ## もっと見るボタンを押す回数

    article_links = []
    ## もっと見るボタンを押してリンクを取得
    j = 0
    click_more_button_count.times do
      driver.find_element(:class_name, 'list-article__more-link').click
      sleep(rand(2..4))
      target_elements = driver.find_elements(:class_name, 'list-article__link')[j..j+39]
      target_elements.each do |e|
        article_links.push(e.attribute('href'))
      end
      j += 40
      sleep(rand(1..3))
    end

    ## スプレッドシートを取得
    session = GoogleDrive::Session.from_config(".config.json")
		sheet = session.spreadsheet_by_key("1LNGQQ1zbO7Iph8QiTkw1UdYVmCxpusAWopdbLbr8FzU").worksheets[0]

    ## 最終行を取得
    i = 2
    while true do
      ## 会社名が書かれていなかったら最終行なのでwhileを抜ける
			data = sheet[i, 1]
			if data.blank?
				break
			end

      ## 連絡禁止か初回アポ済にデータが入っているかチェック データが入っていればDBのデータを書き換える
      ## データがなかった場合、データを保存する
      ## 連絡禁止
      if sheet[i, 7].present?
        target_data = Company.find_by(company_name: sheet[i, 1], email: sheet[i, 3])
        if target_data.present?
          if !target_data.is_blocked_company
            target_data.update(is_blocked_company: true)
          end
        else
          company =Company.new(
            company_name: sheet[i, 1],
            pritimes_url: sheet[i, 2],
            email: sheet[i, 3],
            charge_employee: sheet[i, 4],
            category: sheet[i, 5],
            insert_date_time: sheet[i, 6],
            is_blocked_company: true
          )
          company.save
        end
      end

      ## 初回アポ済
      if sheet[i, 8].present?
        target_data = Company.find_by(company_name: sheet[i, 1], email: sheet[i, 3])
        if target_data.present?
          if !target_data.is_client
            target_data.update(is_client: true)
          end
        else
          company = Company.new(
            company_name: sheet[i, 1],
            pritimes_url: sheet[i, 2],
            email: sheet[i, 3],
            charge_employee: sheet[i, 4],
            category: sheet[i, 5],
            insert_date_time: sheet[i, 6],
            is_client: true
          )
          company.save
        end
      end
			i += 1
		end

    last_row = i ## 最終行を変数に代入

    today = Time.new.strftime("%Y-%m-%d %H:%M:%S")
    CSV.open("prtimes-scrapng #{today}.csv","w", :encoding => "utf-8") do |csv|
      csv << ["会社名", "prtimesのURL", "メールアドレス", "担当者", "カテゴリ", "日時"]
      article_links.each do |link|
        sleep(rand(1..3))
        driver.get(link) ## 各記事に遷移
        sleep(rand(1..3))
        target_element_text = ''
        convert_elements = []
        begin
          target_element_text = driver.find_element(:id, 'media-only-information').text
          convert_elements = target_element_text.split("\n").compact_blank ## 配列形式に直す
        rescue => exception
          p exception
          p link
          next
        end
        if convert_elements.size < 1
          next
        end
        company = Company.new(pritimes_url: link)
        ## 会社名
        company.company_name = driver.find_element(:xpath, '//*[@id="sidebar"]/aside[1]/div[1]').text
        right_content_list = driver.find_elements(:xpath, '//*[@id="containerInformationCompany"]/li')
        right_content_list.each do |content|
          ## 電話番号
          text = content.find_elements(:tag_name, 'span')[1].text
          if text.match(Company::VALID_PHONE_NUMBER_REGEX)
            company.tel = text
            break
          end
        end
        convert_elements.each do |element|
          if element.include?('【') ## 【が入ってるのはいらない
            next
          end
          # メールアドレス
          email = Company::check_email(element)
          if email
            company.email = email
            next
          end
          ## 担当者
          charge_employee = Company::check_charge_employee(element)
          if charge_employee
            company.charge_employee = charge_employee
            next
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

        ## CSVファイルに出力
        csv << [
          company.company_name,
          company.pritimes_url,
          company.email,
          company.charge_employee,
          company.category,
          Time.new.strftime("%Y-%m-%d %H:%M:%S")
        ]

        ## 最終行に追加
        sheet[last_row, 1] = company.company_name
        sheet[last_row, 2] = company.pritimes_url
        sheet[last_row, 3] = company.email
        sheet[last_row, 4] = company.charge_employee
        sheet[last_row, 5] = company.category
        sheet[last_row, 6] = Time.new.strftime("%Y-%m-%d %H:%M:%S")
        sheet.save

        ## DBに保存
        company.save

        last_row += 1
      end
    end
  end
end
