# namespace :data do
#   namespace :extract do
#     task :regulationsdotgov_id, :environment => true do
#       Entry.find(:all, :conditions => "regulationsdotgov_id IS NULL && date_published > '2009-01-01'", :order => "publication_date DESC").each do |entry|
#         
#       end
#     end
#   end
# end