class PresidentialDocumentType < ActiveHash::Base
  self.data = [
    {:id => 1, :name => "Determination",        :node_name => "DETERM"},
    {:id => 2, :name => "Executive Order",      :node_name => "EXECORD"},
    {:id => 3, :name => "Presidential Memo",    :node_name => "PRMEMO"},
    {:id => 4, :name => "Presidential Notice",  :node_name => "PRNOTICE"},
    {:id => 5, :name => "Proclamation",         :node_name => "PROCLA"},
  ]
end
