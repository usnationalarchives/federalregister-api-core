class Admin::DictionaryWordsController < AdminController
  def create
    DictionaryWord.find_or_create_by(word: params[:word].to_s.capitalize_first)
    head :ok
  end
end
