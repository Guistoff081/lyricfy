class ExportsController < ApplicationController
  def create
    project = Project.find(params[:project_id])
    attributes = params.require(:export).permit(:start_seconds, :end_seconds, :aspect).to_h
    attributes["start_seconds"] = 0 if attributes["start_seconds"].blank?
    attributes["end_seconds"] = project.duration if attributes["end_seconds"].blank?
    export = project.exports.new(attributes.merge(subtitle_text: project.subtitle_text, subtitle_position: project.subtitle_position, subtitle_font: project.subtitle_font, subtitle_size: project.subtitle_size))
    if export.save
      redirect_to project, notice: "Exportação adicionada à fila. O worker local processará o vídeo."
    else
      redirect_to project, alert: export.errors.full_messages.join(". ")
    end
  end

  def download
    project = Project.find(params[:project_id])
    export = project.exports.find(params[:id])
    return head :not_found unless export.status == "completed" && export.output_path.file?
    send_file export.output_path, type: "video/mp4", filename: "lyricfy-#{project.id}-#{export.id}.mp4"
  end
end
