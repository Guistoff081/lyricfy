require "json"
require "open3"

module Lyricfy
  class MediaProbe
    class Error < StandardError; end

    def self.call(path)
      stdout, stderr, status = Open3.capture3("ffprobe", "-v", "error", "-show_format", "-show_streams", "-of", "json", File.expand_path(path.to_s))
      raise Error, "Não foi possível ler a mídia: #{stderr.to_s[-2000..] || stderr}" unless status.success?
      data = JSON.parse(stdout)
      streams = data.fetch("streams", [])
      video = streams.find { |stream| stream["codec_type"] == "video" && stream.dig("disposition", "attached_pic") != 1 }
      audio = streams.any? { |stream| stream["codec_type"] == "audio" }
      duration = Float(data.dig("format", "duration") || video&.fetch("duration", nil) || 0)
      raise Error, "A mídia precisa ter duração válida e áudio ou vídeo." unless duration.finite? && duration.positive? && (video || audio)
      { duration: duration, video: !!video, audio: audio, width: video&.fetch("width", nil), height: video&.fetch("height", nil) }
    rescue Errno::ENOENT
      raise Error, "FFprobe não está instalado."
    rescue JSON::ParserError, ArgumentError => error
      raise Error, "Metadados de mídia inválidos: #{error.message}"
    end
  end
end
