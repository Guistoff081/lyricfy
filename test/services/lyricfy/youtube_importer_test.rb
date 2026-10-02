require "test_helper"

class YoutubeImporterTest < ActiveSupport::TestCase
  test "local downloader fixture creates playable project with title and subtitles" do
    Dir.mktmpdir do |directory|
      executable = File.join(directory, "yt-dlp")
      File.write(executable, <<~'RUBY')
        #!/usr/bin/env ruby
        require "json"
        directory = ARGV[ARGV.index("-P") + 1]
        if ARGV.include?("--skip-download")
          File.write(File.join(directory, "source.pt.srt"), "1\n00:00:00,000 --> 00:00:00,800\nCanção de teste\n")
        else
          abort "playlist protection missing" unless ARGV.include?("--no-playlist") && ARGV.include?("--ignore-config")
          File.write(File.join(directory, "source.info.json"), JSON.generate(title: "Título do vídeo", id: "UzGcGNPzsoI"))
          system("ffmpeg", "-v", "error", "-f", "lavfi", "-i", "color=c=blue:s=160x90:d=1", "-c:v", "libx264", "-pix_fmt", "yuv420p", File.join(directory, "source.mp4"), exception: true)
        end
      RUBY
      File.chmod(0o755, executable)
      old_path = ENV["PATH"]
      begin
        ENV["PATH"] = "#{directory}:#{old_path}"
        item = MediaImport.create!(url: "https://youtu.be/UzGcGNPzsoI")
        assert MediaImportProcessor.run_once
        item.reload
        assert_equal "completed", item.status
        assert_equal "Título do vídeo", item.project.title
        assert_includes item.project.subtitle_text, "Canção de teste"
        assert File.file?(item.project.media_path)
        assert_nil item.warning
        assert_not MediaImportProcessor.run_once
      ensure
        ENV["PATH"] = old_path
        FileUtils.rm_rf(item.project.directory) if item&.project
      end
    end
  end

  test "downloader failure persists error without a project" do
    Dir.mktmpdir do |directory|
      executable = File.join(directory, "yt-dlp")
      File.write(executable, "#!/bin/sh\necho 'Video unavailable' >&2\nexit 1\n")
      File.chmod(0o755, executable)
      old_path = ENV["PATH"]
      begin
        ENV["PATH"] = "#{directory}:#{old_path}"
        item = MediaImport.create!(url: "https://youtu.be/UzGcGNPzsoI")
        assert_no_difference("Project.count") { MediaImportProcessor.run_once }
        item.reload
        assert_equal "failed", item.status
        assert_includes item.error_message, "Video unavailable"
      ensure
        ENV["PATH"] = old_path
      end
    end
  end
end
