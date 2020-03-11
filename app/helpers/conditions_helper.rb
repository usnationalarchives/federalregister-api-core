module ConditionsHelper

  def clean_conditions(conditions)
    if conditions.is_a?(Hash)
      conditions.each do |k,v|
        conditions[k] = clean_conditions(v) if v.is_a?(Hash)
        conditions[k] = v.reject{|x| x.blank?} if v.is_a?(Array)
      end

      conditions.delete_if do |k,v|
        if v.is_a?(Array)
          v.empty? || v.join("").empty?

        else
          v.blank?
        end
      end
    end

    # within needs a location to be used
    if conditions.present? && conditions[:near] && !conditions[:near][:location]
      conditions.delete(:near)
    end

    conditions
  end

end
