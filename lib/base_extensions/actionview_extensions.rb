# support www2. as well as www
ActionView::Helpers::TextHelper::AUTO_LINK_RE= %r{ 
  (?: ([\w+.:-]+:)// | www\d?\. )
  [^\s<]+ 
}x
