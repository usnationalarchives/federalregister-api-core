module HashExtensions
  # taken from facets -- lib/core/facets/hash/recursive_merge.rb, line 5
  def recursive_merge(other)
    hash = self.dup
    other.each do |key, value|
      myval = self[key]
      if value.is_a?(Hash) && myval.is_a?(Hash)
        hash[key] = myval.recursive_merge(value)
      else
        hash[key] = value
      end
    end
    hash
  end

  # recursive implementation of active support compact_blank
  def deep_compact_blank
    compact.transform_values do |v|
      case v
      when Hash
        v.deep_compact_blank.compact_blank
      when Array
        v.compact_blank
      else
        v
      end
    end
  end
end

Hash.send(:include, HashExtensions)
