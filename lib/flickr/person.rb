class Flickr
  class Person
    attr_accessor :real_name, :user_name, :location, :profile_url
    
    def initialize(person_id)
      attributes = flickr.people.getInfo(:user_id => person_id)
      @real_name = attributes["realname"]
      @user_name = attributes["username"]
      @location = attributes["location"]
      @profile_url = attributes["profileurl"]
    end
  end
end