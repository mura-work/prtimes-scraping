class Company < ApplicationRecord
  VALID_PHONE_NUMBER_REGEX = /\A0(\d{1}[-(]?\d{4}|\d{2}[-(]?\d{3}|\d{3}[-(]?\d{2}|\d{4}[-(]?\d{1})[-)]?\d{4}\z|\A0[5789]0[-]?\d{4}[-]?\d{4}\z/
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  VALID_EMAIL_TARGET = [
    "MAIL :",
    "Email:",
    "E-MAIL：",
    "E-mail：",
    "E MAIL",
    "mail：",
    "MAIL：",
    "Mail : ",
    "e-mail：",
    "E-Mail：",
    "E-mail:",
    "MAIL:",
    "E：",
    "Mail:",
    "メール：",
    "メール:",
    "電子メール",
    "E-mail",
    "E-mail :",
    "e-mail ：",
    "Mail address：",
    "e-mail:",
    "メールアドレス：",
    "E-Mail ：",
    "Mail：",
  ]
  VALID_CHARGE_EMPLOYEE_TARGET= [
    "担当：",
    "担当者名：",
    "担当者：",
    "広報：",
    "広報 ",
    "担　当：",
    "担当者",
    "担当",
  ]

  class << self
    def check_charge_employee(target)
      target_charge_employee = Company::VALID_CHARGE_EMPLOYEE_TARGET.find { |v| target.include?(v)}
      if !target_charge_employee
        return nil
      end
      idx = target.index(target_charge_employee)
      result = target.slice(idx + target_charge_employee.size, target.size)
      return result.strip
    end

    def check_email(email)
      target_word = Company::VALID_EMAIL_TARGET.find { |v| email.include?(v)}
      if !target_word
        return nil
      end
      idx = email.index(target_word)
      ## 正規表現で切り取ったらいける？
      result = email.slice(idx + target_word.size, email.size)
      return result.strip
    end
  end
end

