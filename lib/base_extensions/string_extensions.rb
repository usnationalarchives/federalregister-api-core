# Copyright (c) 2006-2007 Justin French
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class String
  # Capitalizes only the first character of a string (unlike "string".capitalize), leaving the rest
  # untouched.  spinach => Spinach, CD => CD, cat => Cat, crAzY => CrAzY
  def capitalize_first
    string = self[0,1].capitalize + self[1, self.length]
    return string
  end

  # Capitalizes the first character of all words not found in words_to_skip_capitalization_of()
  # Examples of skipped words include 'of', 'the', 'or', etc.  Also capitalizes the first character
  # of the string regardless.
  def capitalize_most_words
    self.split.collect{ |w| words_to_skip_capitalization_of.include?(w.downcase) ? w : w.capitalize_first }.join(" ").capitalize_first
  end

  # Capitalizes the first character of all words in string
  def capitalize_words
    self.split.collect{ |s| s.capitalize_first }.join(" ")
  end

  private

  # Defines an array of words to which capitalize_most_words() should skip over.
  # TODO: Should "it" be included in the list?
  def words_to_skip_capitalization_of
    [
    'of','a','the','and','an','or','nor','but','if','then','else','when','up','at','from','by','on',
    'off','for','in','out','over','to'
    ]
  end
end
