module SectionHelper
  def description_for_section(section)
    # TODO: move to section model as an attribute, or combine with the existing section description attribute
    case section.title
    when "Money"
      "Documents relating to financial affairs and transactions, including: banks and banking, securities markets and trading, the Federal Reserve System, taxation, Federal grants, government contracts, loan programs, and credit assistance."
    when "Environment"
      "Documents relating to energy and natural resources, including: environmental quality, wildlife and fisheries, mineral resources, public lands, agricultural commodities, air and water pollution, nuclear facilities safety, waterways, and conservation."
    when "World"
      "Documents with international and security implications, including: foreign relations, national defense, emergency preparedness, international trade, domestic security, immigration and naturalization, and intelligence activities."
    when "Science & Technology"
      "Documents relating to scientific and technological matters, including: computing, communications, medical research, space exploration, educational research, food and nutrition research, agricultural research, nuclear power, water resources, and minerals management."
    when "Business & Industry"
      "Documents with commercial implications, including: transportation, navigation, aviation, communications, energy, labor relations and employment, business assistance, trade practices, patents and copyrights, and the Postal Service."
    when "Health & Public Welfare"
      "Documents relating to health, safety, and quality of life, including: food and drug safety, animal and plant health, emergency preparedness, transportation safety, housing, Medicare and Medicaid, children and families, education, community development, consumer protection, legal assistance and crime prevention, and recreation."
    end
  end
end