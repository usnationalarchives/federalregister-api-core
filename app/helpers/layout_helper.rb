module LayoutHelper
  def add_column_class(column_class)
    content_for :column_class do
      "#{column_class}"
    end
  end

  def meta_robots(instructions)
    content_for(:robots) do
      tag(:meta, :name => 'ROBOTS', :content => instructions)
    end
  end
end
