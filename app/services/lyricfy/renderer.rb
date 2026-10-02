require "tmpdir"
require "open3"
require_relative "media_probe"
require_relative "subtitles"

module Lyricfy
  class Renderer
    class Error < StandardError; end
    FORMATS = { "vertical" => [720, 1280], "square" => [720, 720] }.freeze

    def self.call(input_path:, subtitle_text:, output_path:, start_seconds: 0, end_seconds: nil, format: "original", subtitle_position: "center", subtitle_font: "Liberation Serif", subtitle_size: 24)
      raise Error, "Formato inválido." unless ["original", *FORMATS.keys].include?(format)
      alignment = { "top" => 6, "center" => 10, "bottom" => 2 }[subtitle_position]
      raise Error, "Posição de legenda inválida." unless alignment
      raise Error, "Fonte inválida." unless ["Liberation Serif", "Liberation Sans", "Liberation Mono"].include?(subtitle_font)
      raise Error, "Tamanho deve ser um inteiro entre 12 e 48." unless subtitle_size.is_a?(Integer) && (12..48).cover?(subtitle_size)
      metadata = MediaProbe.call(input_path)
      start_at = Float(start_seconds)
      end_at = end_seconds.nil? ? metadata[:duration] : Float(end_seconds)
      unless start_at.finite? && end_at.finite? && start_at >= 0 && end_at > start_at && end_at <= metadata[:duration] + 0.001
        raise Error, "Corte deve estar dentro da duração da mídia."
      end
      input = File.expand_path(input_path.to_s)
      output = File.expand_path(output_path.to_s)
      raise Error, "A saída deve ser diferente da mídia original." if input == output
      cues = Subtitles.clip(Subtitles.parse(subtitle_text), (start_at * 1000).round, (end_at * 1000).round)
      duration = end_at - start_at
      Dir.mktmpdir("lyricfy-render-") do |directory|
        File.write(File.join(directory, "captions.srt"), Subtitles.dump(cues))
        argv = ["ffmpeg", "-hide_banner", "-loglevel", "error", "-nostdin", "-y", "-ss", start_at.to_s, "-i", input]
        dimensions = FORMATS[format]
        unless metadata[:video]
          dimensions ||= [1280, 720]
          argv += ["-f", "lavfi", "-i", "color=c=0x141824:s=#{dimensions.join('x')}:r=25"]
        end
        argv += ["-map", metadata[:video] ? "0:v:0" : "1:v:0", "-map", "0:a:0?"]
        filters = []
        if dimensions
          width, height = dimensions
          filters << "scale=#{width}:#{height}:force_original_aspect_ratio=decrease,pad=#{width}:#{height}:(ow-iw)/2:(oh-ih)/2,setsar=1"
        else
          filters << "pad=ceil(iw/2)*2:ceil(ih/2)*2"
        end
        filters << "subtitles=filename=captions.srt:force_style='Alignment=#{alignment},MarginV=20,FontName=#{subtitle_font},FontSize=#{subtitle_size},Outline=1,Shadow=1'" unless cues.empty?
        argv += ["-vf", filters.join(","), "-t", duration.to_s, "-c:v", "libx264", "-preset", "veryfast", "-crf", "22", "-pix_fmt", "yuv420p", "-c:a", "aac", "-movflags", "+faststart", "-f", "mp4", output]
        _stdout, stderr, status = Open3.capture3(*argv, chdir: directory)
        raise Error, "Falha ao exportar: #{stderr.to_s[-2000..] || stderr}" unless status.success?
      end
      output
    rescue Errno::ENOENT
      raise Error, "FFmpeg não está instalado ou um arquivo não foi encontrado."
    rescue ArgumentError => error
      raise Error, error.message
    end
  end
end
