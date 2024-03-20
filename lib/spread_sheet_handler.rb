class SpreadSheetHandler
	def initialize
		session = GoogleDrive::Session.from_config(".config.json")
		@sheet = session.spreadsheet_by_key("1LNGQQ1zbO7Iph8QiTkw1UdYVmCxpusAWopdbLbr8FzU").worksheets[0]
		@last_row = 1
	end

  def increment_last_row
    @last_row += 1
  end

  ## 最終行を計算してインスタンス変数に格納する
	def set_last_row
		@last_row = 2
    while true do
      ## 会社名が書かれていなかったら最終行なのでwhileを抜ける
			data = @sheet[@last_row, 1]
			if data.blank?
				break
			end

      ## 連絡禁止か初回アポ済にデータが入っているかチェック データが入っていればDBのデータを書き換える
      ## データがなかった場合、データを保存する
      ## 連絡禁止
      if @sheet[@last_row, 8].present?
        target_data = Company.find_by(company_name: @sheet[@last_row, 1], email: @sheet[@last_row, 3])
        if target_data.present?
          if !target_data.is_blocked_company
            target_data.update(is_blocked_company: true)
          end
        else
          company = Company.new(
            company_name: @sheet[@last_row, 1],
            pritimes_url: @sheet[@last_row, 2],
            email: @sheet[@last_row, 3],
            tel: @sheet[@last_row, 4],
            charge_employee: @sheet[@last_row, 5],
            category: @sheet[@last_row, 6],
            insert_date_time: @sheet[@last_row, 7],
            is_blocked_company: true
          )
          company.save
        end
      end

      ## 初回アポ済
      if @sheet[@last_row, 9].present?
        target_data = Company.find_by(company_name: @sheet[@last_row, 1], email: @sheet[@last_row, 3])
        if target_data.present?
          if !target_data.is_client
            target_data.update(is_client: true)
          end
        else
          company = Company.new(
            company_name: @sheet[@last_row, 1],
            pritimes_url: @sheet[@last_row, 2],
            email: @sheet[@last_row, 3],
            tel: @sheet[@last_row, 4],
            charge_employee: @sheet[@last_row, 5],
            category: @sheet[@last_row, 6],
            insert_date_time: @sheet[@last_row, 7],
            is_client: true
          )
          company.save
        end
      end
			@last_row += 1
		end
	end

  def insert_sheet(company)
    ## 最終行に追加
    @sheet[@last_row, 1] = company.company_name
    @sheet[@last_row, 2] = company.pritimes_url
    @sheet[@last_row, 3] = company.email
    @sheet[@last_row, 4] = company.tel
    @sheet[@last_row, 5] = company.charge_employee
    @sheet[@last_row, 6] = company.category
    @sheet[@last_row, 7] = Time.new.strftime("%Y-%m-%d %H:%M:%S")
    @sheet.save
  end
end