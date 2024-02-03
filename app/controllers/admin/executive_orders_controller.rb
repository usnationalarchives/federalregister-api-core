class Admin::ExecutiveOrdersController < AdminController
  extend ExecutiveOrderImportUtils
  
  def index
    respond_to do |wants|
      wants.html do
        load_search!
        if @search.result.to_a.count == 1
          redirect_to edit_admin_executive_order_path(@search.result.first)
        elsif params[:q]
          flash.now[:error] = "Executive order not found"
        end
      end
    end
  end

  def show 
    load_search!
    @executive_order = Entry.where(presidential_document_type_id: 2).find(params[:id])
  end

  def edit
    @executive_order = Entry.where(presidential_document_type_id: 2).find(params[:id])
  end

  def update
    @executive_order = Entry.where(presidential_document_type_id: 2).find(params[:id])
    if @executive_order.update(eo_params)
      # Note: Cache purging handled via EntryObserver
      redirect_to admin_executive_order_path(@executive_order)
      flash[:notice] = "The executive order was updated.  The public-facing site should reflect the updates within one minute."
    else
      flash.now[:error] = "Unable to edit the requested EO, please correct the errors below"
      render :edit
    end
  end

  private

  def load_search!
    @search = Entry.where(presidential_document_type_id: 2).ransack(params[:q])
  end

  def eo_params
    if @executive_order.historical_era_eo?
      params.require(:entry).permit(
        :title,
        :citation,
        :document_number,
        :signing_date, 
        :publication_date,
        :president_id,
        :not_received_for_publication,
        :executive_order_notes
      )
    else
      params.require(:entry).permit(
        :executive_order_notes
      )
    end
  end

end
