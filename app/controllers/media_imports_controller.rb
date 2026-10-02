class MediaImportsController < ApplicationController
  def create
    item = MediaImport.new(url: params[:url])
    if item.save
      redirect_to media_import_path(item)
    else
      redirect_to new_project_path, alert: item.errors.full_messages.join(" ")
    end
  end

  def show
    @import = MediaImport.find(params[:id])
    redirect_to @import.project, notice: @import.warning.presence || "Vídeo e legendas disponíveis importados. Revise a letra antes de exportar." if @import.status == "completed"
  end
end
