class PrivacyActUpdater

  def self.create_unmapped_privacy_act_identifier_csv
    # Query the Govinfo API and generate a CSV based on the PAI identifiers it returns.  We shouldn't need to regenerate this file, but keeping the code available in case we ever want to completely regenerate the CSV source file and re-determine the related agency_slug in our system.
    CSV.open("data/efs/pai_agency_without_mapping.csv", "wb") do |csv|
      csv << [
        "pai_identifier",
        "agency_name",
        "agency_count",  
        "agency_names", # If multiple agencies present, display all variants
        "agency_slug", # Deliberately left blank to be populated manually, LLM, etc.
      ]

      pai_packages = GovInfoClient.new.collections(
        'PAI',
        url_params: {last_modified_start_date: Date.current - 100.days},
        result_klass: GovInfoClient::PaiPackage
      )

      pai_packages.group_by(&:pai_identifier).each do |pai_identifier, pai_packages|
        if EXCLUDED_HISTORICAL_PAI_IDENTIFIERS.exclude? pai_identifier
          csv << [
            pai_identifier,
            pai_packages.first.agency_name,
            pai_packages.map(&:agency_name).uniq.count,
            pai_packages.map(&:agency_name).uniq,
            nil
          ]
        end
      end
    end
  end

  def self.update_agency_pai_identifiers!
    # Updates PAI identifiers if they do not exist based on a static mapping file (pai_agency_mapping.csv)
    agency_attributes = []
    CSV.foreach("data/pai_agency_mapping.csv", headers: true) do |row|
      agency = Agency.find_by_slug(row["agency_slug"])
      if agency && agency.pai_identifier.blank?
        puts agency.pai_identifier
        agency_attributes << {id: agency.id, pai_identifier: row["pai_identifier"]}
      end
    end

    if agency_attributes.present?
      Agency.upsert_all(agency_attributes)
    else
      puts "No agencies with empty pai identifiers located"
    end
  end

  PAI_IDENTIFIER_EXCLUSIONS = ['OA', 'AFRICAN','HISTPRES', 'AGRI', 'BATTLE']
  def self.update_agency_pai_years!
    pai_packages = GovInfoClient.new.collections(
      'PAI',
      url_params: {last_modified_start_date: Date.current - 20.years},
      result_klass: GovInfoClient::PaiPackage
    )

    agency_attributes = []
    pai_packages.group_by(&:pai_identifier).each do |pai_identifier, pai_packages|
      agency = Agency.find_by_pai_identifier(pai_identifier)
      if agency
        pai_year = pai_packages.max_by(&:year).year
        agency_attributes << {id: agency.id, pai_year: pai_year}
      end
    end

    if agency_attributes.present?
      Agency.upsert_all(agency_attributes)
    else
      puts "No agencies with empty pai identifiers located"
    end
  end

  EXCLUDED_HISTORICAL_PAI_IDENTIFIERS = %w(ACTUARIE AFRICAN AGRI ARCHITEC ARM_RET ARTS ASSASSIN BATTLE BLIND CIVIL COMMER COPYRIGH COPYWRIT CORP COURT CSOA CSPC DA DEFENSE DEFNUC DOD_OTHR DOD_SECY EDUCAT ENERGY ETHICS EX_IM FARM FCAB FED_FIN FED_HOME FED_HOUS FED_LAB FED_MED FED_MINE FED_RET FERC FH FIEC FINE_ART FMSHRC FRS HHS_PHS HHS_SAMH HISTPRES HOMELAND IND_COUN IND_GAME INTERIOR INTER_AM INT_BOUN JUS_PRC JUS_TOC JUS_UST LABOR LIBRARY MAMMAL MERIT MKUSF NACIC NAT_CAP NAVAJO NHIRC OA PADC PA_AVE PCEE PCWHF PEACE PENSION POSTAL SEL_SERV SPECIAL STR TRADE TRANS TREAS TRES_TOC TRUMAN USA USIA USMC USTR WATER WRC).to_set # These historical PAI identifiers are excluded since they have new equivalents (eg AFRICAN is now ADF, ACTUARIE is now JBEA, etc.  We want to make sure we don't associate an old PAI identifier with an agency so we avoid linking to older content)
  private_constant :EXCLUDED_HISTORICAL_PAI_IDENTIFIERS

end
  