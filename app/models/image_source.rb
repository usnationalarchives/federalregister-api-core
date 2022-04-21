class ImageSource < ActiveHash::Base
  include ActiveHash::Enum
  enum_accessor :identifier

  self.data = [
    {
      id: 1,
      identifier: "pdf_extraction",
      description: "Extracted from PDF",
      monochrome_transparency: false,
      pre_assigned_density: false,
    },
    {
      id: 2,
      identifier: "gpo_sftp",
      description: "GPO SFTP",
      monochrome_transparency: true,
      pre_assigned_density: false,
    },
    {
      id: 3,
      identifier: "retired_ecfr_dot_gov_pdf",
      description: "Retired ECFR.gov PDF",
      monochrome_transparency: false,
      pre_assigned_density: 300,
    },
  ]
end
