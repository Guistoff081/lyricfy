require "test_helper"
require "open3"
require "tmpdir"

class ProjectWorkflowTest < ActionDispatch::IntegrationTest
  self.use_transactional_tests = true

  setup do
    @workspace = Dir.mktmpdir("lyricfy-workflow-")
    @source = File.join(@workspace, "song.wav")
    _, error, status = Open3.capture3("ffmpeg", "-v", "error", "-f", "lavfi", "-i", "sine=frequency=440:duration=3", @source)
    assert status.success?, error
    @created_projects = []
  end

  teardown do
    @created_projects.each { |project| FileUtils.rm_rf(project.directory) }
    FileUtils.remove_entry(@workspace)
  end

  test "import, save, snapshot, render a nonzero cut and download" do
    post projects_path, params: { project: { title: "Minha faixa", media: Rack::Test::UploadedFile.new(@source, "audio/wav") } }
    project = Project.order(:id).last
    @created_projects << project
    assert_redirected_to project_path(project)
    assert project.media_path.file?
    assert_equal "audio", project.media_kind

    srt = "1\n00:00:00,500 --> 00:00:02,500\nNossa voz\n"
    patch project_path(project), params: { project: { subtitle_text: srt, subtitle_position: "bottom", subtitle_font: "Liberation Sans", subtitle_size: 32 } }
    assert_redirected_to project_path(project)
    get subtitles_project_path(project, format: :vtt)
    assert_response :success
    assert_includes response.body, "00:00:00.500 --> 00:00:02.500"
    get project_path(project)
    assert_response :success

    post project_exports_path(project), params: { export: { start_seconds: "1", end_seconds: "2", aspect: "square" } }
    assert_redirected_to project_path(project)
    export = project.exports.last
    assert_equal "queued", export.status
    assert_equal "bottom", project.reload.subtitle_position
    assert_equal "bottom", export.subtitle_position
    assert_equal "Liberation Sans", export.subtitle_font
    assert_equal 32, export.subtitle_size
    project.update!(subtitle_text: srt.sub("Nossa voz", "Nova versão"), subtitle_position: "top", subtitle_font: "Liberation Mono", subtitle_size: 18)
    assert_equal "bottom", export.reload.subtitle_position
    assert_equal srt, export.reload.subtitle_text
    assert_equal "Liberation Sans", export.subtitle_font
    assert_equal 32, export.subtitle_size
    assert ExportProcessor.run_once
    assert_equal "completed", export.reload.status, export.error_message
    metadata = Lyricfy::MediaProbe.call(export.output_path)
    assert_in_delta 1, metadata[:duration], 0.15
    assert_equal metadata[:width], metadata[:height]
    get download_project_export_path(project, export)
    assert_response :success
    assert_equal "video/mp4", response.media_type
  end

  test "invalid media shows a useful validation error without creating a project" do
    bad = File.join(@workspace, "invalid.txt")
    File.write(bad, "not media")
    assert_no_difference "Project.count" do
      post projects_path, params: { project: { title: "Inválido", media: Rack::Test::UploadedFile.new(bad, "text/plain") } }
    end
    assert_response :unprocessable_entity
    assert_includes response.body, "Não foi possível ler a mídia"
  end

  test "video import retains source bytes and exports picture audio and saved SRT" do
    source = File.join(@workspace, "clip.mp4")
    _, error, status = Open3.capture3("ffmpeg", "-v", "error", "-f", "lavfi", "-i",
      "color=c=blue:s=320x240:r=25:d=2", "-i", @source, "-t", "2", "-c:v", "libx264",
      "-pix_fmt", "yuv420p", "-c:a", "aac", source)
    assert status.success?, error
    original = File.binread(source)
    post projects_path, params: { project: { title: "Vídeo português", media: Rack::Test::UploadedFile.new(source, "video/mp4") } }
    project = Project.order(:id).last
    @created_projects << project
    assert_equal "video", project.media_kind
    assert_equal original, File.binread(project.media_path)
    get media_project_path(project), headers: { "Range" => "bytes=10-29" }
    assert_response :partial_content
    assert_equal original.byteslice(10, 20), response.body
    assert_equal "bytes 10-29/#{original.bytesize}", response.headers["Content-Range"]
    get media_project_path(project), headers: { "Range" => "bytes=#{original.bytesize + 1}-" }
    assert_response :range_not_satisfiable
    srt = "1\n00:00:00,000 --> 00:00:01,500\nCanção, coração e manhã\n"
    patch project_path(project), params: { project: { subtitle_text: srt } }
    assert_redirected_to project_path(project)
    get subtitles_project_path(project, format: :srt)
    assert_response :success
    assert_equal srt, response.body
    post project_exports_path(project), params: { export: { start_seconds: "", end_seconds: "", aspect: "original" } }
    assert ExportProcessor.run_once
    export = project.exports.last
    assert_equal "completed", export.status, export.error_message
    metadata = Lyricfy::MediaProbe.call(export.output_path)
    assert metadata[:video]
    assert metadata[:audio]
    assert_equal [320, 240], metadata.values_at(:width, :height)
    assert_in_delta 2, metadata[:duration], 0.15
    assert_equal original, File.binread(project.media_path)
    assert_equal original, File.binread(source)
    get download_project_export_path(project, export)
    assert_response :success
  end

  test "invalid subtitles and reversed cuts preserve saved data" do
    post projects_path, params: { project: { title: "Faixa", media: Rack::Test::UploadedFile.new(@source, "audio/wav") } }
    project = Project.order(:id).last
    @created_projects << project
    patch project_path(project), params: { project: { subtitle_text: "broken" } }
    assert_response :unprocessable_entity
    assert_equal "", project.reload.subtitle_text
    project.update!(subtitle_text: "1\n00:00:00,000 --> 00:00:01,000\nTeste\n")
    assert_no_difference "Export.count" do
      post project_exports_path(project), params: { export: { start_seconds: "2", end_seconds: "1", aspect: "original" } }
    end
    assert_redirected_to project_path(project)
  end
end
