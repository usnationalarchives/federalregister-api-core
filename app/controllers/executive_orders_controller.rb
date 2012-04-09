class ExecutiveOrdersController < ApplicationController
  FIELDS = [:executive_order_number, :title, :publication_date, :signing_date, :citation, :document_number]
  
  def index
    @orders_by_president_and_year = ExecutiveOrderPresenter.all_by_president_and_year
    @api_conditions = {
      :type => "PRESDOCU",
      :presidential_document_type_id => 2,
      :correction => 0
    }

    @fields = FIELDS
  end

  def by_president_and_year
    @orders_by_president_and_year = ExecutiveOrderPresenter.all_by_president_and_year

    @president = President.find_by_identifier(params[:president])
    @year = params[:year].to_i

    @eo_collection = ExecutiveOrderPresenter::EoCollection.new(@president, @year)

    @api_conditions = {
      :type => "PRESDOCU",
      :presidential_document_type_id => 2,
      :president => @president.identifier,
      :publication_date => {:year => @year},
      :correction => 0
    }

    @fields = FIELDS
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
