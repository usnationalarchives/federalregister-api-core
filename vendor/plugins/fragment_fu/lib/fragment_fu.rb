require 'fragment_fu/render_with_esi_option'
require "fragment_fu/invalidation_helper"
ActionController::Base.send(:include, FragmentFu::InvalidationHelper)
ActionView::Base.send(:include, FragmentFu::RenderWithEsi)