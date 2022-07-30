require 'json'
require 'csv'
require 'selenium-webdriver'

namespace :scraping_prtimes do
  desc 'prtimesのスクレイピング'
  task csv: :environment do
    driver = Selenium::WebDriver.for :chrome
    PR_TIMES_URL = 'https://prtimes.jp'
    PR_TIMES_LOGIN_URL = 'https://prtimes.jp/main/html/medialogin'

    article_links = []

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
    target_url = PR_TIMES_URL + '/technology/'
    driver.get(target_url)
    sleep(rand(1..3))


    ## 取得するデータ件数を代入
    get_count = 200 ## 取得件数
    click_more_button_count = get_count / 40 ## もっと見るボタンを押す回数

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

    i = 0
    today = Time.new.strftime("%Y-%m-%d %H:%M:%S")

    data_contents = []
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
        i += 1
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
      ## 備考を作って全部ぶち込む
      data_contents << company
      i += 1
    end

    # file = File.new("/Users/aoikatto/Desktop/prtimes-scrapng #{today}.txt","w")
    CSV.open("prtimes-scrapng #{today}.csv","w", :encoding => "utf-8") do |csv|
      csv << ["会社名", "担当者", "電話番号", "メールアドレス", "prtimesのURL"] ## todo: 備考欄を作る
      data_contents.each do |company|
        csv << [
          company.company_name,
          company.charge_employee,
          company.tel,
          company.email,
          company.pritimes_url,
        ]
      end
      p csv
    end
    p '終わり'
  end
end
