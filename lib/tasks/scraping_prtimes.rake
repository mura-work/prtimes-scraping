require 'json'
require 'csv'
require 'selenium-webdriver'

namespace :scraping_prtimes do
  desc 'prtimesのスクレイピング'
  task scraping: :environment do
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
    get_count = 80 ## 取得件数
    click_more_button_count = get_count / 40 - 1 ## もっと見るボタンを押す回数

    ## もっと見るボタンを押してリンクを取得
    j = 0
    click_more_button_count.times do
      driver.find_element(:class_name, 'list-article__more-link').click
      sleep(rand(2..4))
      target_elements = driver.find_elements(:class_name, 'list-article__link')[j..j+39]
      target_elements.each do |e|
        article_links.push(e.attribute('href'))
      end
      j += 1
      sleep(rand(1..3))
    end

    i = 0
    article_links.each do |link|
      sleep(rand(1..3))
      driver.get(link) ## 各記事に遷移
      sleep(rand(1..3))

      begin
        today = Date.today.strftime("%Y-%m-%d %H:%M:%S")
        file = File.new("prtimes-scrapng #{today}.txt","w")
        target_element_text = driver.find_element(:id, 'media-only-information').text
        convert_elements = target_element_text.split("\n").reject(&:blank?) ## 配列形式に直す
        file.puts(convert_elements)
        file.puts('')
      rescue => exception
        i += 1
        next
      ensure
        file.close
      end

      i += 1
    end
  end
end
