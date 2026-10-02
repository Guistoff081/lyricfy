require "uri"

class MediaImport < ApplicationRecord
  belongs_to :project, optional: true
  validates :status, inclusion: { in: %w[queued running completed failed] }
  validate :youtube_url

  def self.canonical_url(value)
    uri = URI.parse(value.to_s.strip)
    raise ArgumentError unless %w[http https].include?(uri.scheme) && uri.userinfo.nil? && [80, 443].include?(uri.port)
    id = case uri.host&.downcase
    when "youtu.be" then uri.path.delete_prefix("/")
    when "youtube.com", "www.youtube.com", "m.youtube.com", "music.youtube.com"
      if uri.path == "/watch"
        URI.decode_www_form(uri.query.to_s).to_h["v"]
      elsif uri.path.match?(%r{\A/(shorts|embed)/})
        uri.path.split("/").last
      end
    end
    raise ArgumentError unless id&.match?(/\A[A-Za-z0-9_-]{11}\z/)
    "https://www.youtube.com/watch?v=#{id}"
  rescue URI::InvalidURIError, ArgumentError
    raise ArgumentError, "Cole o link de um vídeo do YouTube (não uma playlist)."
  end

  private

  def youtube_url
    self.url = self.class.canonical_url(url)
  rescue ArgumentError => error
    errors.add(:url, error.message)
  end
end
