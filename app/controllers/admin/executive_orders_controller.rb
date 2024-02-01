class Admin::ExecutiveOrdersController < AdminController
  extend ExecutiveOrderImportUtils
  
  def index
    respond_to do |wants|
      wants.html do
        @search = Entry.where(presidential_document_type_id: 2).ransack(params[:q])
        if @search.result.to_a.count == 1
          redirect_to edit_admin_executive_order_path(@search.result.first)
        else
          flash.now[:error] = "Executive order not found"
        end
      end
    end
  end

  def show 
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

  def eo_params
    params.require(:entry).permit(:document_number, :publication_date, :signing_date, :executive_order_notes)
  end

end
