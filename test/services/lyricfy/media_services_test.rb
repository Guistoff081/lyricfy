require "minitest/autorun"
require "tmpdir"
require_relative "../../../app/services/lyricfy/renderer"

class MediaServicesTest < Minitest::Test
  SRT = "1\n00:00:00,500 --> 00:00:01,500\nPrimeira linha\n\n2\n00:00:02,000 --> 00:00:03,500\nSegunda linha\n"

  def test_caption_position_changes_pixels_in_the_rendered_frame
    Dir.mktmpdir do |directory|
      input = File.join(directory, "black.mp4")
      _, error, status = Open3.capture3("ffmpeg", "-v", "error", "-f", "lavfi", "-i", "color=black:s=320x288:d=1", "-c:v", "libx264", input)
      assert status.success?, error
      ["top", "center", "bottom"].each_with_index do |position, band|
        output = File.join(directory, "#{position}.mp4")
        Lyricfy::Renderer.call(input_path: input, output_path: output, subtitle_text: "1\n00:00:00,000 --> 00:00:01,000\nPosição\n", subtitle_position: position, subtitle_font: "Liberation Sans", subtitle_size: 18)
        frame, error, status = Open3.capture3("ffmpeg", "-v", "error", "-i", output, "-frames:v", "1", "-pix_fmt", "gray", "-f", "rawvideo", "-")
        assert status.success?, error
        white_rows = frame.bytes.each_with_index.filter_map { |pixel, index| index / 320 if pixel > 180 }
        refute_empty white_rows
        assert white_rows.all? { |y| (band * 96...(band + 1) * 96).cover?(y) }, "#{position}: #{white_rows.min}..#{white_rows.max}"
      end
      assert_raises(Lyricfy::Renderer::Error) do
        Lyricfy::Renderer.call(input_path: input, output_path: File.join(directory, "invalid.mp4"), subtitle_text: SRT, subtitle_position: "invalid")
      end
    end
  end

  def test_renumber_preserves_text_and_invalid_timing
    source = "9\r\n00:00:01,000 --> 00:00:04,000\r\nTexto\r\n2026\r\n\r\n9\r\nSem intervalo\r\nTexto\r\n\r\n15\r\n00:00:02,000 --> 00:00:03,000\r\nOutro"
    expected = source.sub("9\r\n", "1\r\n").sub("\r\n9\r\n", "\r\n2\r\n").sub("\r\n15\r\n", "\r\n3\r\n")
    assert_equal expected, Lyricfy::Subtitles.renumber(source)
    assert_raises(Lyricfy::Subtitles::Error) { Lyricfy::Subtitles.parse(Lyricfy::Subtitles.renumber(source)) }
  end

  def test_srt_round_trip_and_clip
    cues = Lyricfy::Subtitles.parse(SRT)
    assert_equal cues, Lyricfy::Subtitles.parse(Lyricfy::Subtitles.dump(cues))
    assert_equal [{ start_ms: 0, end_ms: 500, text: "Primeira linha" }, { start_ms: 1000, end_ms: 2000, text: "Segunda linha" }], Lyricfy::Subtitles.clip(cues, 1000, 3000)
    assert_includes Lyricfy::Subtitles.vtt(cues), "00:00:00.500 --> 00:00:01.500"
  end

  def test_rejects_invalid_timing_encoding_and_overlap
    assert_raises(Lyricfy::Subtitles::Error) { Lyricfy::Subtitles.parse(SRT.sub("00:00:00,500", "00:70:00,500")) }
    assert_raises(Lyricfy::Subtitles::Error) { Lyricfy::Subtitles.parse(SRT.sub("00:00:02,000", "00:00:01,000")) }
    assert_raises(Lyricfy::Subtitles::Error) { Lyricfy::Subtitles.parse("\xFF".b) }
    assert_raises(Lyricfy::Subtitles::Error) { Lyricfy::Subtitles.parse("1\n00:00:01,000 --> 00:00:01,000\nText") }
  end

  def test_render_nonzero_cut_and_audio_background
    skip "FFmpeg unavailable" unless system("ffmpeg", "-version", out: File::NULL, err: File::NULL)
    Dir.mktmpdir("lyricfy-test") do |directory|
      input = File.join(directory, "input with ' quotes.mp4")
      output = File.join(directory, "output.mp4")
      _stdout, stderr, status = Open3.capture3("ffmpeg", "-hide_banner", "-loglevel", "error", "-f", "lavfi", "-i", "color=blue:s=320x240:r=25:d=4", "-f", "lavfi", "-i", "sine=frequency=440:duration=4", "-c:v", "libx264", "-c:a", "aac", "-shortest", input)
      assert status.success?, stderr
      Lyricfy::Renderer.call(input_path: input, subtitle_text: SRT, output_path: output, start_seconds: 1, end_seconds: 3, format: "square")
      metadata = Lyricfy::MediaProbe.call(output)
      assert_in_delta 2, metadata[:duration], 0.15
      assert_equal [720, 720], metadata.values_at(:width, :height)
      assert metadata[:audio]
      # Frame differences establish that a cue crossing the cut starts immediately,
      # disappears in the gap, and the later cue is shifted to one second.
      hashes = [0.2, 0.7, 1.2].map do |at|
        frame, error, result = Open3.capture3("ffmpeg", "-v", "error", "-ss", at.to_s, "-i", output, "-frames:v", "1", "-f", "md5", "-")
        assert result.success?, error
        frame
      end
      refute_equal hashes[0], hashes[1]
      refute_equal hashes[1], hashes[2]
      audio = File.join(directory, "audio.wav")
      _, stderr, status = Open3.capture3("ffmpeg", "-v", "error", "-i", input, "-vn", audio)
      assert status.success?, stderr
      Lyricfy::Renderer.call(input_path: audio, subtitle_text: SRT, output_path: output, start_seconds: 1, end_seconds: 2, format: "vertical")
      assert_equal [720, 1280], Lyricfy::MediaProbe.call(output).values_at(:width, :height)
      assert_raises(Lyricfy::Renderer::Error) { Lyricfy::Renderer.call(input_path: input, subtitle_text: SRT, output_path: output, end_seconds: 20) }
    end
  end
end
