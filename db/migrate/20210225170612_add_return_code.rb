class AddReturnCode < ActiveRecord::Migration[6.1]
  def change
    add_column :participants, :rejoin_code, :string
  end
end
