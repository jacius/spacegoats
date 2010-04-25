require 'physical_stage'

class MainStage < PhysicalStage

  def setup
    super

    @boat = create_actor( :boat, opts[:boat] || {} )

    @water_color = Rubygame::Color::ColorHSL.new([0.56, 0.8, 0.2])

  end

  def draw(target)
    target.fill @water_color
    super
  end

end
