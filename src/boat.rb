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

  attr_accessor :turning_left,  :turning_right,
                :motor_fore,    :motor_back

  def setup
    self.action = :idle

    @turn_max   = 5             # max turn rate
    @turn_accel = 1.2           # acceleration when turning
    @turn_decay = 0.2           # spin slowdown when not turning (0 - 1)

    @spd_max    = 30            # max boat speed
    @spd_back   = 10            # max speed when motoring backwards
    @spd_accel  = 10            # acceleration when motoring
    @spd_decay  = 0.98          # slowdown when not motoring (0 - 1)

    @turning_left  = false
    @turning_right = false
    @motor_fore    = false
    @motor_back    = false

    i = input_manager
    i.while_key_pressed( :left,  self, :turning_left  )
    i.while_key_pressed( :right, self, :turning_right )
    i.while_key_pressed( :up,    self, :motor_fore    )
    i.while_key_pressed( :down,  self, :motor_back    )

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
    motor = (@motor_fore ? 1 : 0) + (@motor_back ? -1 : 0)

    dir = vec2(1,0).rotate(body.rot)

    body.reset_forces

    case motor
    when 1                      # forward
      body.f = dir * motor * @spd_max * body.m
    when -1                     #  backward
      body.f = dir * motor * @spd_back * body.m
    else                        # drifting
      body.v *= @spd_decay ** seconds
    end

    # Slow down if going too fast
    if body.v.length < @spd_max
      body.v *= @spd_decay ** seconds
    end

  end

end
