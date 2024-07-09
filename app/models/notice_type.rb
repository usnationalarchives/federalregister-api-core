class NoticeType < ActiveHash::Base
  include ActiveHash::Enum
  enum_accessor :identifier

  self.data = [
    {
      :id                         => 1,
      :name                       => "SORN",
      :identifier                 => "sorn",
    },
    {
      :id                         => 2,
      :name                       => "Sunshine Act Meeting",
      :identifier                 => "sunshine_act_meeting",
    },
  ]

end
