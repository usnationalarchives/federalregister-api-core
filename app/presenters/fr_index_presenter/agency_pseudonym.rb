class FrIndexPresenter
  AgencyPseudonym = Struct.new(:agency) do
    def name
      agency.pseudonym
    end

    def see_instead
      agency
    end

    def entry_count
      0
    end

    def first_letter
      name.chars.first
    end
  end
end
