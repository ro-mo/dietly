class AddDetailsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :type, :string
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :phone, :string
    add_column :users, :fiscal_code, :string
  end
end
