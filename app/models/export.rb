class Export < ApplicationRecord
  belongs_to :project
  validates :status, inclusion: { in: %w[queued running completed failed] }
  validates :aspect, inclusion: { in: %w[original vertical square] }
  validates :subtitle_text, presence: true
  validates :start_seconds, numericality: { greater_than_or_equal_to: 0 }
  validates :end_seconds, numericality: { greater_than: 0 }
  validate :valid_interval

  def output_path
    project.directory.join("exports", "#{id}.mp4")
  end

  validates :subtitle_position, inclusion: { in: %w[top center bottom] }

  validates :subtitle_font, inclusion: { in: ["Liberation Serif", "Liberation Sans", "Liberation Mono"] }
  validates :subtitle_size, numericality: { only_integer: true, greater_than_or_equal_to: 12, less_than_or_equal_to: 48 }

  private

  def valid_interval
    return unless start_seconds && end_seconds && project
    errors.add(:end_seconds, "deve ser maior que o início e não ultrapassar a mídia") unless start_seconds.finite? && end_seconds.finite? && end_seconds > start_seconds && end_seconds <= project.duration
  end
end
