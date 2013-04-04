class Admin::DictionaryWordsController < AdminController
  def create
    DictionaryWord.find_or_create_by_word(params[:word].to_s.capitalize_first)
    render :nothing => true
  end
end
