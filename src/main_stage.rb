require 'physical_stage'
require 'wind'

class MainStage < PhysicalStage

  def setup
    super

    @boat = create_actor( :boat, opts[:boat] || {} )

    i = input_manager
    i.while_key_pressed( :left,  @boat, :turning_left  )
    i.while_key_pressed( :right, @boat, :turning_right )
    i.while_key_pressed( :up,    @boat, :motor_fore    )
    i.while_key_pressed( :down,  @boat, :motor_back    )


    @boat = create_actor( :boat, :x => 130, :y => 200, :angle => 20 )
    @boat = create_actor( :boat, :x => 250, :y => 100, :angle => 80 )
    @boat = create_actor( :boat, :x => 500, :y => 400, :angle => 30 )


    # Not really used
    @wind = Wind.new( opts[:wind] || {} )

    @water_color = Rubygame::Color::ColorHSL.new([0.56, 0.8, 0.2])

  end

  def draw(target)
    target.fill @water_color
    super
  end

end
