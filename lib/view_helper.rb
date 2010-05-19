module ViewHelper
  class Helper
    include Singleton
    include ActionView::Helpers::TextHelper
    
    # add other helpers here as needed
  end
  
  private
  
  def view_helper
    Helper.instance
  end
end