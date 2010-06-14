class SpecialController < ApplicationController
  def home
    @sections          = Section.all
  end
end
