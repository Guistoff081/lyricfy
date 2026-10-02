require "test_helper"

class MediaImportsTest < ActionDispatch::IntegrationTest
  test "queue canonicalizes one video and exposes pending import" do
    assert_difference("MediaImport.count") do
      post media_imports_path, params: { url: "https://youtu.be/UzGcGNPzsoI?list=RDUzGcGNPzsoI" }
    end
    item = MediaImport.last
    assert_equal "https://www.youtube.com/watch?v=UzGcGNPzsoI", item.url
    assert_equal "queued", item.status
    follow_redirect!
    assert_response :success
    assert_select "[role=status]", "Na fila de importação."
    get root_path
    assert_select "a[href=?]", media_import_path(item)
  end

  test "rejects arbitrary hosts and playlists without a video" do
    ["file:///etc/passwd", "https://localhost/video", "https://youtube.com.evil.test/watch?v=UzGcGNPzsoI", "https://youtube.com/playlist?list=123", "https://user@youtube.com/watch?v=UzGcGNPzsoI"].each do |url|
      assert_no_difference("MediaImport.count") { post media_imports_path, params: { url: url } }
      assert_redirected_to new_project_path
    end
  end
end
