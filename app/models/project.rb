class Project < ApplicationRecord
  has_many :exports, dependent: :destroy
  validates :title, presence: true, length: { maximum: 160 }
  validates :original_filename, presence: true
  validates :media_kind, inclusion: { in: %w[audio video] }
  validates :duration, numericality: { greater_than: 0 }
  before_validation :renumber_subtitles
  validate :valid_subtitles

  def directory
    Rails.root.join("storage", Rails.env, "projects", id.to_s)
  end

  def media_path
    directory.join("source")
  end

  validates :subtitle_position, inclusion: { in: %w[top center bottom] }

  validates :subtitle_font, inclusion: { in: ["Liberation Serif", "Liberation Sans", "Liberation Mono"] }
  validates :subtitle_size, numericality: { only_integer: true, greater_than_or_equal_to: 12, less_than_or_equal_to: 48 }

  private

  def renumber_subtitles
    self.subtitle_text = Lyricfy::Subtitles.renumber(subtitle_text) if subtitle_text.present?
  end

  def valid_subtitles
    return if subtitle_text.blank?
    cues = Lyricfy::Subtitles.parse(subtitle_text)
    errors.add(:subtitle_text, "contém tempos além da duração da mídia") if cues.any? { |cue| cue[:end_ms] > (duration.to_f * 1000).round + 100 }
  rescue ArgumentError => e
    errors.add(:subtitle_text, e.message)
  end
end
