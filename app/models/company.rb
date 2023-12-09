class Company < ApplicationRecord
  VALID_EMAIL_REGEX = /\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b/
  VALID_PHONE_NUMBER_REGEX = /(\d{2,5}-\d{1,4}-\d{4})/
  # VALID_CHARGE_EMPLOYEE_TARGET = [
  #   "担当者名：",
  #   "担当者名:",
  #   "担当者名",
  #   "担当者：",
  #   "担当者",
  #   "広報：",
  #   "広報 ",
  #   "担当：",
  #   "担当:",
  #   "担　当：",
  #   "担当",
  # ]
  VALID_CHARGE_EMPLOYEE_TARGET = /(?:担当者名：|担当者名:|担当者名|担当者：|担当者|広報：|広報 |担当：|担当:|担当\s*：|担当)\s*[:：]?\s*([^\n]+)/

  CONST_CATEGORY = {
    technology: "テクノロジー",
    mobile: "モバイル",
    app: "アプリ",
    entertainment: "エンタメ",
    beauty: "ビューティー",
    fashion: "ファッション",
    lifestyle: "ライフスタイル",
    business: "ビジネス",
    gourmet: "グルメ",
    sports: "スポーツ",
  }

  ## 除外するメールアドレスの末尾
  EMAIL_END_TARGET_EXCLUSION = [
    '@vectorinc.co.jp'
  ]
end

