class Admin::PilAgencyLettersController < AdminController
  include CacheUtils
  include CloudfrontUtils

  def index
    @pil_agency_letter = PilAgencyLetter.new
    load_pil_agency_letters
  end

  def create
    @pil_agency_letter = PilAgencyLetter.new(pil_agency_letter_params)
    if @pil_agency_letter.public_inspection_document.present? && pil_agency_letter_params[:file]
      @pil_agency_letter.file.instance_write(:file_name, modified_file_name)
    end

    if @pil_agency_letter.save
      load_pil_agency_letters
      flash[:notice] = "PIL agency letter created"
      expire_pil_doc_cache
    else
      load_pil_agency_letters
      flash.now[:error] = "Unable to create PIL agency letter--please resolve the errors below"
    end
    render :action => :index
  end

  def destroy
    @pil_agency_letter = PilAgencyLetter.find(params[:id])
    path = "/#{@pil_agency_letter.file.path}"
    @pil_agency_letter.destroy!
    expire_pil_doc_cache
    create_invalidation(
      Settings.s3_buckets.public_inspection,
      Array.wrap(path)
    )
    flash[:notice] = "PIL agency letter deleted"
    redirect_to admin_pil_agency_letters_path
  end

  private

  def pil_agency_letter_params
    params.require(:pil_agency_letter).permit(
      :file,
      :public_inspection_document_id,
    )
  end

  def load_pil_agency_letters
    pil_doc_ids = PilAgencyLetter.pluck(:public_inspection_document_id).uniq
    @pil_docs = PublicInspectionDocument.
      where(id: pil_doc_ids).
      joins(:pil_agency_letters).
      group(:document_number)
  end

  def expire_pil_doc_cache
    purge_cache(api_v1_public_inspection_documents_path + '*')
    purge_cache '^/api/v1/public-inspection'
    purge_cache public_inspection_document_path(@pil_agency_letter.public_inspection_document).
      sub(/[^\/]+\z/, '')
  end

  def modified_file_name
    public_inspection_document = @pil_agency_letter.public_inspection_document

    if public_inspection_document.pil_agency_letters.count > 0
      letter_suffix = public_inspection_document.pil_agency_letters.count + 1
    end

    "letter#{letter_suffix}_#{public_inspection_document.document_number}_#{public_inspection_document.agencies.map(&:short_name).join('-')}#{file_extension}"
  end

  def file_extension
    File.extname(pil_agency_letter_params[:file].original_filename)
  end


end
