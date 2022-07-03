class Company < ApplicationRecord
  VALID_PHONE_NUMBER_REGEX = /\A0(\d{1}[-(]?\d{4}|\d{2}[-(]?\d{3}|\d{3}[-(]?\d{2}|\d{4}[-(]?\d{1})[-)]?\d{4}\z|\A0[5789]0[-]?\d{4}[-]?\d{4}\z/
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  class << self
    def check_charge_employee(target)
      if target.includes('担当')
        return nil
      end
    end

    def check_email(target)
      if element.match(Company::VALID_EMAIL_REGEX)
      end
    end
  end
end

