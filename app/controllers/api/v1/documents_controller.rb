class Api::V1::DocumentsController < ApplicationController
  before_action :set_tenant
  before_action :set_document, only: [:show, :update, :destroy]
  
  def create
    @document = Current.tenant.documents.build(document_params)
    
    if @document.save
      render json: document_response(@document), status: :created
    else
      render json: { errors: @document.errors }, status: :unprocessable_entity
    end
  end
  
  def show
    # Generate signed URL for secure access
    if @document.pdf_file.attached?
      pdf_url = rails_blob_url(@document.pdf_file, expires_in: 1.hour)
      render json: document_response(@document).merge(pdf_url: pdf_url)
    else
      render json: { error: 'No file attached' }, status: :not_found
    end
  end
  
  private
  
  def set_tenant
    Current.tenant = Tenant.find_by!(subdomain: request.subdomain)
  end
  
  def set_document
    @document = Current.tenant.documents.find(params[:id])
  end
  
  def document_params
    params.require(:document).permit(:title, :description, :pdf_file)
  end
  
  def document_response(document)
    {
      id: document.id,
      title: document.title,
      description: document.description,
      filename: document.pdf_file.filename,
      size: document.pdf_file.byte_size,
      created_at: document.created_at
    }
  end
end