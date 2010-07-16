module TextHelper
  def truncate_words(text, options)
    length = options[:length] || 30
    omission = options[:omission] || '...'
    
    if text.length <= length
      text
    else
      words = text.split(/\s+/)
      l = length - omission.length
      
      words.inject('') do |str, word|
        new_str = str == '' ? word : "#{str} #{word}"
        if new_str.length > l
          return str + omission
        else
          str = new_str
        end
      end
    end
  end
end