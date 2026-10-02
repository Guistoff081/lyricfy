module Lyricfy
  class Subtitles
    class Error < ArgumentError; end
    TIMESTAMP = /\A(\d{2,}):([0-5]\d):([0-5]\d),(\d{3})\z/

    # Only replace numeric block headers; retain malformed blocks for validation.
    def self.renumber(text)
      index = 0
      text.to_s.gsub(/(\A(?:\uFEFF)?|\r?\n[ \t]*\r?\n)([ \t]*)\d+([ \t]*)(?=\r?\n|\z)/) do
        index += 1
        "#{Regexp.last_match(1)}#{Regexp.last_match(2)}#{index}#{Regexp.last_match(3)}"
      end
    end

    def self.parse(text)
      source = text.to_s.dup.force_encoding(Encoding::UTF_8)
      raise Error, "A legenda deve ser UTF-8 válida." unless source.valid_encoding?
      source = source.delete_prefix("\uFEFF").gsub("\r\n", "\n").strip
      return [] if source.empty?
      cues = source.split(/\n[ \t]*\n/).map do |block|
        lines = block.lines.map(&:chomp)
        raise Error, "Bloco SRT inválido." unless lines.shift&.match?(/\A\d+\z/)
        timing = lines.shift.to_s.split(" --> ", -1)
        raise Error, "Intervalo SRT inválido." unless timing.size == 2
        { start_ms: milliseconds(timing[0]), end_ms: milliseconds(timing[1]), text: lines.join("\n") }
      end
      validate(cues)
    end

    def self.validate(cues)
      previous_end = 0
      cues.each do |cue|
        start_ms, end_ms = cue.values_at(:start_ms, :end_ms)
        unless start_ms.is_a?(Integer) && end_ms.is_a?(Integer) && start_ms >= previous_end && end_ms > start_ms
          raise Error, "Legendas devem ter tempos válidos, ordenados e sem sobreposição."
        end
        raise Error, "O texto da legenda não pode ficar vazio." if cue[:text].to_s.strip.empty?
        previous_end = end_ms
      end
      cues
    end

    def self.dump(cues)
      validate(cues).each_with_index.map do |cue, index|
        "#{index + 1}\n#{timestamp(cue[:start_ms])} --> #{timestamp(cue[:end_ms])}\n#{cue[:text]}\n"
      end.join("\n")
    end

    def self.clip(cues, start_ms, end_ms)
      raise Error, "Intervalo de corte inválido." unless start_ms.is_a?(Integer) && end_ms.is_a?(Integer) && start_ms >= 0 && end_ms > start_ms
      validate(cues).filter_map do |cue|
        next if cue[:end_ms] <= start_ms || cue[:start_ms] >= end_ms
        { start_ms: [cue[:start_ms] - start_ms, 0].max, end_ms: [cue[:end_ms], end_ms].min - start_ms, text: cue[:text] }
      end
    end

    def self.vtt(cues)
      "WEBVTT\n\n" + validate(cues).map do |cue|
        "#{timestamp(cue[:start_ms]).tr(',', '.')} --> #{timestamp(cue[:end_ms]).tr(',', '.')}\n#{cue[:text]}\n"
      end.join("\n")
    end

    def self.milliseconds(value)
      match = TIMESTAMP.match(value)
      raise Error, "Tempo SRT inválido: #{value}" unless match
      hours, minutes, seconds, millis = match.captures.map(&:to_i)
      ((hours * 60 + minutes) * 60 + seconds) * 1000 + millis
    end

    def self.timestamp(value)
      hours, remainder = value.divmod(3_600_000)
      minutes, remainder = remainder.divmod(60_000)
      seconds, millis = remainder.divmod(1000)
      format("%02d:%02d:%02d,%03d", hours, minutes, seconds, millis)
    end
  end
end
