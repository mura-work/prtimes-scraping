class CreateCompanies < ActiveRecord::Migration[6.1]
  def change
    create_table :companies do |t|

      t.string :company_name, :default => "", :limit => 190
      t.string :tel, :default => "", :limit => 190
      t.string :email, :default => "", :limit => 190
      t.string :address, :default => "", :limit => 190
      t.string :company_site, :default => "", :limit => 190
      t.string :pritimes_url, :default => "", :limit => 190
      t.string :charge_employee, :default => "", :limit => 190
      t.string :category, :default => "", limit: 190
      t.boolean :is_client, :default => false
      t.boolean :is_blocked_company, :default => false
      t.timestamps
    end
  end
end
