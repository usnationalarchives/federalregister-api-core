module Shared::SlugTrait
  as_trait do |options|
    before_validation_on_create :slugify
    validates_uniqueness_of :slug

    private

    define_method :slugify do
      self.slug = "#{self.send(options[:based_on]).downcase.gsub(/[^a-z0-9]+/, '-')}"
    end
  end
end
