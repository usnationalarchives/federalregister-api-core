class PresidentialDocumentType < ActiveHash::Base
  include ActiveHash::Enum
  enum_accessor :identifier

  self.data = [
    {:id => 1, :name => "Determination",      :node_name => "DETERM",    :identifier => "determination"},
    {:id => 2, :name => "Executive Order",    :node_name => "EXECORD",   :identifier => "executive_order"},
    {:id => 3, :name => "Memorandum",         :node_name => "PRMEMO",    :identifier => "memorandum"},
    {:id => 4, :name => "Notice",             :node_name => "PRNOTICE",  :identifier => "notice"},
    {:id => 5, :name => "Proclamation",       :node_name => "PROCLA",    :identifier => "proclamation"},
    {:id => 6, :name => "Presidential Order", :node_name => "PRORDER",   :identifier => "presidential_order"},
  ]

  def self.find_as_hash(options)
    methods = options[:select].split(/\s*,\s*/)
    Hash[data.map{|rec| methods.map{|m| rec[m.to_sym].to_s}}]
  end
end
