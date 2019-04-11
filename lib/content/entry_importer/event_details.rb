module Content::EntryImporter::EventDetails
  extend Content::EntryImporter::Utils
  provides :events

  def events
    events = entry.events.reject{|e| %w(EffectiveDate CommentsOpen CommentsClose).include?(e.event_type)}
    date = mods_node.css('effectiveDate').first.try(:content)
    if date
      events << Event.new(:date => date, :event_type => 'EffectiveDate')
    end

    date = mods_node.css('commentDate').first.try(:content)
    if date
      events << Event.new(:date => date, :event_type => 'CommentsClose')
      events << Event.new(:date => entry.publication_date, :event_type => 'CommentsOpen')
    end

    events
  end
end
