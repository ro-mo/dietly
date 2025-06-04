class AddAdditionalDetailsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :date_of_birth, :date
    add_column :users, :gender, :string
    add_column :users, :height, :decimal, precision: 5, scale: 2
    add_column :users, :weight, :decimal, precision: 5, scale: 2
    add_column :users, :address, :string
    add_column :users, :city, :string
    add_column :users, :postal_code, :string
  end
end
