#  Add methods to Enumerable, which makes them available to Array
module Enumerable

  #  average of an array of numbers
  def average
    return self.sum/self.length.to_f
  end

end
