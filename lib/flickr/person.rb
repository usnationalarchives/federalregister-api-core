class Flickr::Person
  attr_reader :attributes

  ATTRIBUTES = [
    :description,
    :id,
    :license,
    :lightbox_url,
    :location,
    :nsid,
    :path_alias,
    :realname,
    :title,
    :username,
  ]

  def self.find(conditions)
    client = Flickr::Client.new

    results = JSON.parse(
      client.get(
        conditions.merge(
          :method => 'flickr.photos.getInfo'
        )
      )
    )

    new(results['photo'])
  end

  def initialize(attributes)
    @attributes = attributes
  end

  def description
    attributes['description'] ? attributes['description']['_content'] : ""
  end

  def id
    attributes['id']
  end

  def license
    license = Flickr::Licenses.licenses.find{|l| l.id == attributes['license']}

    if license
      {:name => license.name, :url => license.url}
    else
      {}
    end
  end

  def lightbox_url
    user = path_alias.present? ? path_alias : nsid

    "https://www.flickr.com/photos/#{user}/#{id}/in/photostream/lightbox/"
  end

  def location
    attributes['owner']['location']
  end

  def nsid
    attributes['owner']['nsid']
  end

  def path_alias
    attributes['owner']['path_alias']
  end

  def realname
    attributes['owner']['realname']
  end

  def title
    attributes['title']['_content']
  end

  def username
    attributes['owner']['username']
  end

  # only output our attributes as json
  def as_json(options={})
    # note we're ignoring the user's options but accept them for compatibility
    attrs = {}
    ATTRIBUTES.each{|a| attrs[a] = self.send(a)}
    attrs
  end

  def to_json(*a)
    as_json.to_json(*a)
  end
end
