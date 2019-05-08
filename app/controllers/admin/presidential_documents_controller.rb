class Admin::PresidentialDocumentsController < AdminController
  extend ExecutiveOrderImportUtils
  layout 'admin_bootstrap'

  def index
  end

  def show
    file_identifier = params[:id]
    if self.class.job_finished?(file_identifier)
      @message = 'The file has been successfully processed.'
    elsif self.class.job_failed?(file_identifier)
      @message = 'File processing failed.'
    else
      @message = 'Processing file...'
      @status  = 'continue-polling'
    end
  end

  def create
    if params[:upload].blank?
      flash.now[:error] = "A file must be provided before uploading!"
      render :index
    elsif params[:upload][:csv_file].original_filename.split('.').last != "csv"
      flash.now[:error] = "The file must be in CSV format in order to be processed!"
      render :index
    else
      save_file!
      file_identifier = Digest::SHA256.hexdigest(File.read(file_path))
      Resque.enqueue(Admin::ExecutiveOrderImporterEnqueuer, file_path, file_identifier)
      self.class.record_job_status(file_identifier, false)

      redirect_to admin_presidential_document_path(file_identifier)
    end
  end


  private

  DATA_DIRECTORY = 'data/efs/admin/imports/'
  def save_file!
    FileUtils.mkdir_p DATA_DIRECTORY
    FileUtils.cp(params[:upload][:csv_file].path, file_path)
  end

  def file_identifier
    Digest::SHA256.hexdigest(File.read(file_path))
  end

  def file_path
    @file_path ||= File.join(DATA_DIRECTORY, "executive_order_import_#{Time.current.to_s(:underscored_iso_date_then_time)}.csv")
  end

end
