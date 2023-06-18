# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

require File.expand_path(File.dirname(__FILE__) + "/environment")
set :output, 'log/cron.log' # ログの出力先ファイルを設定

rails_env = Rails.env.to_sym
set :environment, rails_env # 環境を設定

job_type :rake, "export PATH=\"$HOME/.rbenv/bin:$PATH\"; eval \"$(rbenv init -)\"; cd :path && RAILS_ENV=:environment bundle exec rake :task :output"

every 1.days, at: '1:00 am' do # 1日1回実行
  # rake "import_movies:popular_movies"
  rake "scraping_latest_data:sheet"
end