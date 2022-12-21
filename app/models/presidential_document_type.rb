class PresidentialDocumentType < ActiveHash::Base
  include ActiveHash::Enum
  enum_accessor :identifier

  self.data = [
    {
      :id                         => 1,
      :name                       => "Determination",
      :node_name                  => "DETERM",
      :identifier                 => "determination",
      :entry_collection_formatter => Proc.new do |entries|
        # Format: Presidential Determination No. 17-14, p.
        entries.map{|x| "Presidential Determination No. , p."}
      end,
    },
    {
      :id                         => 2,
      :name                       => "Executive Order",
      :node_name                  => "EXECORD",
      :identifier                 => "executive_order",
      :entry_collection_formatter => Proc.new do |entries|
        # Format: EOs 13769, 13780
        if entries.count > 1
          pluralized_form = "EOs"
        else
          pluralized_form = "EO"
        end

        eo_numbers = entries.map do |entry|
          entry.executive_order_number
        end.join(", ")

        "#{pluralized_form} #{eo_numbers}"
      end
    },
    {
      :id                         => 3,
      :name                       => "Memorandum",
      :node_name                  => "PRMEMO",
      :identifier                 => "memorandum",
      :entry_collection_formatter => Proc.new do |entries|
        # Format: Memorandums of Mar. 19, p. ; Apr. 12, p. ; June 29, p. 
        if entries.count > 1
          pluralized_form = "Memorandums"
        else
          pluralized_form = "Memorandum"
        end

        signing_dates = entries.map do |entry|
          "#{entry.signing_date.try(:to_s, :abbrev_month_day)} p. "
        end.join("; ")

        "#{pluralized_form} of #{signing_dates}"
      end
    },
    {
      :id                         => 4,
      :name                       => "Notice",
      :node_name                  => "PRNOTICE",
      :identifier                 => "notice",
      :entry_collection_formatter => Proc.new do |entries|
        # Format: Notices of July 19, p. ; July 20, p. 
        if entries.count > 1
          pluralized_form = "Notices"
        else
          pluralized_form = "Notice"
        end

        signing_dates = entries.map do |entry|
          "#{entry.signing_date.try(:to_s, :abbrev_month_day)} p. "
        end.join("; ")

        "#{pluralized_form} of #{signing_dates}"
      end
    },
    {
      :id                         => 5,
      :name                       => "Proclamation",
      :node_name                  => "PROCLA",
      :identifier                 => "proclamation",
      :entry_collection_formatter => Proc.new do |entries|
        # Proc. 9614)
        if entries.count > 1
          pluralized_form = "Procs."
        else
          pluralized_form = "Proc."
        end

        proclamation_numbers = entries.map do |entry|
          entry.proclamation_number
        end.join(", ")

        "#{pluralized_form} #{proclamation_numbers}"
      end
    },
    {
      :id                         => 6,
      :name                       => "Presidential Order",
      :node_name                  => "PRORDER",
      :identifier                 => "presidential_order",
      :entry_collection_formatter => Proc.new do |entries|
        # Format: Order of May 23, p. 
        if entries.count > 1
          pluralized_form = "Order"
        else
          pluralized_form = "Orders"
        end

        signing_dates = entries.map do |entry|
          "#{entry.signing_date.try(:to_s, :abbrev_month_day)} p. "
        end.join("; ")

        "#{pluralized_form} of #{signing_dates}"
      end
    },
    {
      :id                         => 7,
      :name                       => "Other",
      :node_name                  => "OTHER",
      :identifier                 => "other",
    },
  ]

  def self.find_as_hash(options)
    methods = options[:select].split(/\s*,\s*/)
    Hash[data.map{|rec| methods.map{|m| rec[m.to_sym]}}]
  end

  def self.active_hash?
    true
  end
end
