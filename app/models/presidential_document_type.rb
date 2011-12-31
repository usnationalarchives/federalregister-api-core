class PresidentialDocumentType < ActiveHash::Base
  include ActiveHash::Enum
  enum_accessor :identifier

  self.data = [
    {:id => 1, :name => "Determination",      :node_name => "DETERM",    :identifier => "determination"},
    {:id => 2, :name => "Executive Order",    :node_name => "EXECORD",   :identifier => "executive_order"},
    {:id => 3, :name => "Memorandum",         :node_name => "PRMEMO",    :identifier => "memorandum"},
    {:id => 4, :name => "Notice",             :node_name => "PRNOTICE",  :identifier => "notice"},
    {:id => 5, :name => "Proclamation",       :node_name => "PROCLA",    :identifier => "proclamation"},
  ]
end
