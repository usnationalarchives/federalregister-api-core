module LayoutHelper
  def add_controller_class(controller_name)
    col_class = controller_name == 'special' ? 'home' : ''
    col_class
  end
end
