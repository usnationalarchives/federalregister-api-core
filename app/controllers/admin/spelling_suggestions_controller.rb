class Admin::SpellingSuggestionsController < AdminController
  def index
    checker = SpellChecker.new
    suggestions = checker.suggestions_for( params[:word] )
    checker.close

    render :json => { :suggestions => suggestions }
  end
end
