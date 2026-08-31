class AddFrontPageRankToArticles < ActiveRecord::Migration[ 8.1 ]
  def change
    add_column :articles, :front_page_rank, :integer
    add_index :articles, :front_page_rank
  end
end
