class EntrySearch::Suggestor::RegulationIdNumber < EntrySearch::Suggestor::Base
  private
  
  def pattern
    /(\w{4}-\w{4})/
  end
  
  def handle_match(rin)
    reg_plan = RegulatoryPlan.find_by_regulation_id_number(rin)
    
    if reg_plan
      @conditions[:regulation_id_number] = rin
    else
      @conditions = nil
    end
  end
  
end