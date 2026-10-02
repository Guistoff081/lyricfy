require "tmpdir"
require "json"
require "timeout"

module Lyricfy
  class YoutubeImporter
    class Error < StandardError; end

    def self.call(url)
      url = MediaImport.canonical_url(url)
      Dir.mktmpdir("lyricfy-import-") do |directory|
        common = ["yt-dlp", "--ignore-config", "--no-playlist", "--no-progress", "--socket-timeout", "30", "--retries", "2", "--restrict-filenames", "-P", directory, "-o", "source.%(ext)s"]
        run(common + ["--write-info-json", "--no-write-playlist-metafiles", "-f", "bv*[vcodec^=avc1]+ba[ext=m4a]/b[ext=mp4]/b", "--merge-output-format", "mp4", "--recode-video", "mp4", "--", url], directory)
        info = JSON.parse(File.read(File.join(directory, "source.info.json")))
        path = File.join(directory, "source.mp4")
        raise Error, "O download não produziu um vídeo MP4." unless File.file?(path)
        metadata = MediaProbe.call(path)
        warning = nil
        subtitles = ""
        begin
          run(common + ["--skip-download", "--write-subs", "--write-auto-subs", "--sub-langs", "pt-BR,pt,en", "--sub-format", "srt/vtt/best", "--convert-subs", "srt", "--", url], directory)
          subtitle = %w[pt-BR pt en].map { |lang| File.join(directory, "source.#{lang}.srt") }.find { |file| File.file?(file) }
          if subtitle
            subtitles = Subtitles.dump(Subtitles.parse(File.read(subtitle, encoding: "UTF-8")))
          else
            warning = "Sem legenda disponível em português ou inglês. Importe um SRT ou adicione linhas no editor."
          end
        rescue Error, ArgumentError => error
          warning = "Vídeo importado, mas a legenda precisa ser adicionada manualmente: #{error.message.to_s.first(400)}"
        end
        project = Project.new(title: info.fetch("title", "Vídeo do YouTube").to_s.first(160), original_filename: "#{info.fetch('id', 'video')}.mp4", media_kind: metadata[:video] ? "video" : "audio", duration: metadata[:duration], subtitle_text: subtitles)
        unless project.valid?
          project.subtitle_text = ""
          warning = "A legenda disponível não atende à validação de tempos do editor. Importe um SRT revisado."
        end
        begin
          Project.transaction do
            project.save!
            FileUtils.mkdir_p(project.directory)
            FileUtils.cp(path, project.media_path)
          end
        rescue StandardError
          FileUtils.rm_rf(project.directory) if project.id
          raise
        end
        [project, warning]
      end
    rescue Errno::ENOENT => error
      raise Error, "Dependência ou arquivo ausente: #{error.message}. Verifique yt-dlp e FFmpeg."
    end

    def self.run(arguments, directory)
      log = File.join(directory, "process.log")
      File.open(log, "w") do |output|
        pid = Process.spawn(*arguments, out: output, err: output, pgroup: true)
        begin
          _, status = Timeout.timeout(1800) { Process.wait2(pid) }
          unless status.success?
            output.flush
            message = File.open(log) { |file| file.seek([file.size - 2000, 0].max); file.read }
            raise Error, "yt-dlp não conseguiu concluir: #{message}"
          end
        rescue Timeout::Error
          Process.kill("KILL", -pid) rescue Errno::ESRCH
          Process.wait(pid) rescue Errno::ECHILD
          raise Error, "A importação excedeu 30 minutos. Tente novamente."
        end
      end
    end
  end
end
