class Flickr::Photo
  attr_reader :attributes

  # white list the attributes we care about
  ATTRIBUTES = [
    :farm,
    :id,
    :license,
    :owner,
    :secret,
    :server,
  ]

  # make attributes accessible as methods
  ATTRIBUTES.each do |attr|
    define_method(attr) { attributes[attr.to_s] }
  end

  def self.search(conditions)
    client = Flickr::Client.new

    results = JSON.parse(
      client.get(
        conditions.merge(
          :method => 'flickr.photos.search',
          :media => 'photos'
        )
      )
    )

    results['photos']['photo'].map do |attributes|
      new(attributes)
    end
  end

  def initialize(attributes)
    @attributes = attributes
  end

  def url(size)
    "https://farm#{farm}.staticflickr.com/#{server}/#{id}_#{secret}_#{size}.jpg"
  end

  # only output our attributes as json
  def as_json(options={})
    # note we're ignoring the user's options but accept them for compatibility
    attrs = {}
    ATTRIBUTES.each{|a| attrs[a] = self.send(a)}
    attrs[:url_sm] = url('q')
    attrs[:url_lg] = url('o')
    attrs
  end

  def to_json(*a)
    as_json.to_json(*a)
  end
end
