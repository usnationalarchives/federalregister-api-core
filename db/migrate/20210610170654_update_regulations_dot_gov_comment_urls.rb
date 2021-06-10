class UpdateRegulationsDotGovCommentUrls < ActiveRecord::Migration[6.0]
  def change
    Entry.where.not(comment_url: nil).find_each do |entry|
      new_comment_url = entry.comment_url.gsub('http://www.regulations.gov/#!submitComment;D=', 'http://www.regulations.gov/commenton/')
      entry.update_column(:comment_url, new_comment_url)
    end
  end
end
