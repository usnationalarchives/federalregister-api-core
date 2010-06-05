module SearchHelper
  def first_10_and_current(facets)
    first_10 = facets[0,10]
    on = facets[10,10000].try(:find, &:on?)
    if on.present?
      first_10 + [on]
    else
      first_10
    end
  end
end