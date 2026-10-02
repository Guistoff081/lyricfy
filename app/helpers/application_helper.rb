module ApplicationHelper
  ICONS = %w[moon folders upload device-desktop plus download refresh device-floppy movie music arrow-left arrow-right player-track-next x].freeze

  def icon(name)
    raise ArgumentError, "Ícone desconhecido" unless ICONS.include?(name)
    image_tag "/icons/#{name}.svg", alt: "", class: "studio-icon", aria: { hidden: true }, width: 20, height: 20
  end
end
