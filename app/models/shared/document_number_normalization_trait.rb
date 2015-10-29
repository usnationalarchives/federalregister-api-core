module Shared::DocumentNumberNormalizationTrait
  as_trait do
    def self.find_by_document_number(document_number, options={})
      doc = first(:conditions => {:document_number => document_number})
      if doc.nil?
        normalized_document_number = normalize_document_number(document_number)
        if normalized_document_number != document_number
          doc = first(:conditions => {:document_number => normalized_document_number})
        end

        padded_document_number = pad_document_number(document_number)
        if padded_document_number != document_number
          doc = first(:conditions => {:document_number => padded_document_number})
        end
      end

      doc
    end

    def self.find_by_document_number!(document_number, options={})
      find_by_document_number(document_number) or raise ActiveRecord::RecordNotFound
    end

    def self.normalize_document_number(document_number)
      first_part, rest = document_number.split(/-/, 2)
      if rest =~ /^\d+$/
        rest.sub!(/^0*/,'')
      end
      [first_part, rest].reject(&:blank?).join('-')
    end

    def self.pad_document_number(document_number)
      part_1, part_2 = document_number.split(/-/, 2)
      sprintf("%s-%05d", part_1, part_2.to_i)
    end
  end
end
