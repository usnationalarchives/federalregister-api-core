class ExecutiveOrdersController < ApplicationController
  def index
    @presidents = President.all.reverse
  end

  def by_president_and_year
    @presidents = President.all.reverse

    @president = President.find_by_identifier(params[:president])
    @year = params[:year].to_i
    @executive_orders = Entry.executive_order.published_in(@president.year_ranges[@year]).scoped(:order => "executive_order_number DESC")

    raise ActiveRecord::RecordNotFound unless @executive_orders.present?
  end

  def show
    entry = Entry.find_by_presidential_document_type_id_and_executive_order_number!(
      PresidentialDocumentType::EXECUTIVE_ORDER.id,
      params[:number]
    )

    respond_to do |wants|
      wants.html do
        redirect_to entry_path(entry)
      end
      wants.pdf do
        redirect_to entry.source_url(:pdf)
      end
    end
  end
end
