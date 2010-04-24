require 'actor'
require 'actor_view'


class BoatView < GraphicalActorView
  # def draw(target, x_off, y_off)
  #   super target, x_off, y_off
  # end
end


class Boat < Actor

  has_behaviors :updatable, :animated, :audible

  has_behaviors :physical => {
    :shape      => :poly, 
    :mass       => 20,
    :friction   => 0.4,
    :elasticity => 0.2,
    :verts      => [[-5,-15], [-5, 15],
                    [ 5, 15], [ 5,-15]]
  }

  attr_reader :turning_left, :turning_right

  def setup
    self.action = :idle

    @turn_max   = 5
    @turn_accel = 0.2 + 1
    @turn_decay = 0.2

    @turning_left  = false
    @turning_right = false

    i = input_manager

    i.reg( KeyPressed,  :left  ){  @turning_left  = true   }
    i.reg( KeyReleased, :left  ){  @turning_left  = false  }

    i.reg( KeyPressed,  :right ){  @turning_right = true   }
    i.reg( KeyReleased, :right ){  @turning_right = false  }
  end


  def update( time_ms )
    seconds = time_ms * 0.001

    calc_rotation( seconds )
    calc_force( seconds )

    super
  end


  private

  def calc_rotation( seconds )
    turn = 0
    turn -= 1 if @turning_left
    turn += 1 if @turning_right

    if turn != 0
      if body.w.abs < @turn_max
        body.w += turn * @turn_accel ** seconds
      else
        body.w = turn * @turn_max 
      end
    else
      body.w *= @turn_decay ** seconds
    end
  end


  def calc_force( seconds )
    body.reset_forces

    # TODO: calculate from the wind
    push = 500
    body.f = vec2(1,0).rotate(body.rot) * push
  end

end
