class ExportProcessor
  def self.run_once
    candidate = Export.where(status: "queued").order(:id).first
    return false unless candidate
    claimed = Export.where(id: candidate.id, status: "queued").update_all(status: "running", updated_at: Time.current)
    return true unless claimed == 1
    begin
      FileUtils.mkdir_p(candidate.output_path.dirname)
      Lyricfy::Renderer.call(input_path: candidate.project.media_path.to_s,
        subtitle_text: candidate.subtitle_text, output_path: candidate.output_path.to_s,
        start_seconds: candidate.start_seconds, end_seconds: candidate.end_seconds, format: candidate.aspect, subtitle_position: candidate.subtitle_position, subtitle_font: candidate.subtitle_font, subtitle_size: candidate.subtitle_size)
      metadata = Lyricfy::MediaProbe.call(candidate.output_path)
      raise Lyricfy::Renderer::Error, "A exportação não contém uma trilha de vídeo válida." unless metadata[:video]
      candidate.update!(status: "completed")
    rescue StandardError => e
      FileUtils.rm_f(candidate.output_path)
      candidate.update!(status: "failed", error_message: e.message.truncate(2000))
      Rails.logger.error("Export #{candidate.id}: #{e.class}: #{e.message}")
    end
    true
  end
end
