module TextHelper
  def truncate_words(text, options)
    return if text.nil?
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

  ROMANS = %w(undef I II III IV V VI VII VIII IX X XI XII XIII XIV XV XVI XVII XVIII XIX XX XXI XXII XXIII XXIV XXV XXVI XXVII XXVIII XXIX XXX)
  def number_to_roman(i)
    ROMANS[i.to_i]
  end
end
