class EsPublicInspectionDocumentSearch < EsApplicationSearch
  private

  def set_defaults(options)
    @within = 25
    @order = options[:order] || 'relevant'
  end
end
