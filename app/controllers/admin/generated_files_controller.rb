class Admin::GeneratedFilesController < AdminController
  layout 'admin_bootstrap'
  
  def show
    @generated_file = GeneratedFile.find(params[:id])

    if @generated_file.processing_completed_at
      render :action => :generated
    else
      render :action => :generating
    end
  end
end