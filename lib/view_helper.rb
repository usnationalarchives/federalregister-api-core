module ViewHelper
  class Helper
    include Singleton
    include ActionView::Helpers::TextHelper

    # add other helpers here as needed
    include TextHelper
  end

  private

  def view_helper
    Helper.instance
  end
end