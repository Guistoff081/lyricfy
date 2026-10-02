require "test_helper"

class ExportProcessorTest < ActiveSupport::TestCase
  test "render failure is persisted without losing the saved revision" do
    project = Project.create!(title: "Fonte ausente", original_filename: "missing.wav", media_kind: "audio", duration: 3,
      subtitle_text: "1\n00:00:00,000 --> 00:00:01,000\nMinha revisão\n")
    export = project.exports.create!(subtitle_text: project.subtitle_text, end_seconds: 2)
    begin
      assert ExportProcessor.run_once
      assert_equal "failed", export.reload.status
      assert export.error_message.present?
      assert_equal "Minha revisão", Lyricfy::Subtitles.parse(project.reload.subtitle_text).first[:text]
      assert_not export.output_path.exist?
      assert_not ExportProcessor.run_once
    ensure
      FileUtils.rm_rf(project.directory)
    end
  end
end
