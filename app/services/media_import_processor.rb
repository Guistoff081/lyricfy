class MediaImportProcessor
  def self.run_once
    item = MediaImport.where(status: "queued").order(:id).first
    return false unless item
    return true unless MediaImport.where(id: item.id, status: "queued").update_all(status: "running", updated_at: Time.current) == 1
    begin
      project, warning = Lyricfy::YoutubeImporter.call(item.url)
      item.update!(status: "completed", project: project, warning: warning, error_message: nil)
    rescue StandardError => error
      item.update!(status: "failed", error_message: error.message.to_s.first(3000))
    end
    true
  end
end
