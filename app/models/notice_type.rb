class NoticeType < ActiveHash::Base
  include ActiveHash::Enum
  enum_accessor :identifier

  self.data = [
    {
      :id                         => 1,
      :name                       => "SORN",
      :identifier                 => "sorn",
    },
  ]

end
