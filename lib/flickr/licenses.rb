class Flickr::Licenses
  attr_reader :attributes

  # white list the attributes we care about
  ATTRIBUTES = [
    :id,
    :name,
    :url,
  ]

  # make attributes accessible as methods
  ATTRIBUTES.each do |attr|
    define_method(attr) { attributes[attr.to_s] }
  end

  def self.licenses
    client = Flickr::Client.new

    results = JSON.parse(
      client.get(
        :method => 'flickr.photos.licenses.getInfo'
      )
    )

    results['licenses']['license'].map do |attributes|
      new(attributes)
    end
  end

  def initialize(attributes)
    @attributes = attributes
  end
end
