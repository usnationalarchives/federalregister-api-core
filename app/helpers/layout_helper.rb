module LayoutHelper
  def add_column_class(column_class)
    content_for :column_class do
      "#{column_class}"
    end
  end
end
