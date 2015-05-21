module Content::EntryImporter::Action
  extend Content::EntryImporter::Utils
  provides :action_name
  
  def action_name
    action_node = @bulkdata_node && @bulkdata_node.css('ACT P').first
    if action_node && action_node.text
      name = action_node.text.slice(0,255) #truncate at 255 chars
      ActionName.find_by_name(name) || ActionName.create(:name => name)
    end
  end
end

