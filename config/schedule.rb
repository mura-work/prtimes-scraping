# require File.expand_path(File.dirname(__FILE__) + "/environment")
# set :output, 'log/cron.log' # ログの出力先ファイルを設定

rails_env = ENV['RAILS_ENV'] ||= 'production'
set :output, 'log/cron.log'
set :environment, rails_env
ENV.each { |k, v| env(k, v) }

# rails_env = Rails.env.to_sym
# set :environment, rails_env # 環境を設定

job_type :rake, "export PATH=\"$HOME/.rbenv/bin:$PATH\"; eval \"$(rbenv init -)\"; cd :path && RAILS_ENV=:environment bundle exec rake :task :output"

# バッチ処理の実行テスト
# every 1.minute do
#   rake "test_connect_spreadsheet:test"
# end

every 1.days, at: '0:00 am' do # 1日1回実行
  rake "scraping_latest_data:sheet"
end
