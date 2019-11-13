module Shared::DoesSlug
  as_trait do |options|
    before_validation :slugify, on: :create
    validates_uniqueness_of :slug

    private

    define_method :slugify do
      self.slug = "#{self.send(options[:based_on]).downcase.gsub(/[^a-z0-9]+/, '-')}"
    end
  end
end
