class ChangeIsbnTitleToBooks < ActiveRecord::Migration[7.0]
  def change
    change_column :books, :isbn, :string
  end
end
