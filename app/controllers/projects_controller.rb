class ProjectsController < ApplicationController
  before_action :set_project, only: %i[show update media subtitles]

  def index
    @projects = Project.order(created_at: :desc)
    @imports = MediaImport.where(project_id: nil).order(created_at: :desc).limit(20)
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(title: params.dig(:project, :title))
    upload = params.dig(:project, :media)
    unless upload.is_a?(ActionDispatch::Http::UploadedFile)
      @project.errors.add(:base, "Selecione um arquivo de áudio ou vídeo.")
      return render :new, status: :unprocessable_entity
    end
    metadata = Lyricfy::MediaProbe.call(upload.tempfile.path)
    @project.assign_attributes(original_filename: File.basename(upload.original_filename), media_kind: metadata[:video] ? "video" : "audio", duration: metadata[:duration])
    if @project.save
      begin
        FileUtils.mkdir_p(@project.directory)
        FileUtils.cp(upload.tempfile.path, @project.media_path)
      rescue StandardError
        @project.destroy!
        raise
      end
      redirect_to @project, notice: "Mídia importada. Agora adicione e revise a letra em SRT."
    else
      render :new, status: :unprocessable_entity
    end
  rescue ArgumentError, Lyricfy::MediaProbe::Error => e
    @project.errors.add(:base, e.message)
    render :new, status: :unprocessable_entity
  end

  def show
    @exports = @project.exports.order(created_at: :desc)
  end

  def update
    if @project.update(params.require(:project).permit(:subtitle_text, :subtitle_position, :subtitle_font, :subtitle_size))
      redirect_to @project, notice: "Legenda salva. A prévia já usa esta versão."
    else
      @exports = @project.exports.order(created_at: :desc)
      render :show, status: :unprocessable_entity
    end
  end

  def media
    response.headers["Accept-Ranges"] = "bytes"
    if request.headers["Range"].present?
      size = File.size(@project.media_path)
      ranges = Rack::Utils.get_byte_ranges(request.headers["Range"], size)
      unless ranges&.one?
        response.headers["Content-Range"] = "bytes */#{size}"
        return head :range_not_satisfiable
      end
      range = ranges.first
      response.headers["Content-Range"] = "bytes #{range.begin}-#{range.end}/#{size}"
      length = range.end - range.begin + 1
      response.headers["Content-Length"] = length.to_s
      response.headers["Content-Type"] = Marcel::MimeType.for(@project.media_path, name: @project.original_filename)
      self.status = :partial_content
      path = @project.media_path
      self.response_body = Enumerator.new do |chunks|
        File.open(path, "rb") do |file|
          file.seek(range.begin)
          remaining = length
          while remaining.positive?
            chunk = file.read([remaining, 64 * 1024].min)
            break unless chunk
            chunks << chunk
            remaining -= chunk.bytesize
          end
        end
      end
      return
    end
    send_file @project.media_path, disposition: "inline", filename: @project.original_filename,
      type: Marcel::MimeType.for(@project.media_path, name: @project.original_filename)
  end

  def subtitles
    cues = Lyricfy::Subtitles.parse(@project.subtitle_text)
    if params[:format] == "vtt"
      send_data Lyricfy::Subtitles.vtt(cues), type: "text/vtt", disposition: "inline"
    else
      send_data Lyricfy::Subtitles.dump(cues), type: "application/x-subrip", filename: "lyricfy-#{@project.id}.srt"
    end
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end
end
