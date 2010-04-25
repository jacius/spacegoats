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

    @turn_max   = 0.5           # max turn rate
    @turn_accel = 0.3           # acceleration when turning
    @turn_decay = 0.2           # spin slowdown when not turning (0 - 1)
    @turn_still = 0.2           # how well you can turn when not moving
    @turn_mod   = 1.2           # turnability modifier

    @spd_max    = 30            # max boat speed
    @spd_back   = 10            # max speed when motoring backwards
    @spd_accel  = 10            # acceleration when motoring
    @spd_decay  = 0.98          # slowdown when not motoring (0 - 1)

    # Tendency of the boat to change its movement vector to be in line
    # with the way it's pointing. (0 - 1)
    @dir_adjust = 0.7

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
    adjust_movement( seconds )
    calc_force( seconds )

    super
  end


  private


  def calc_rotation( seconds )
    turn = 0
    turn -= 1 if @turning_left
    turn += 1 if @turning_right

    # You can turn a boat better when it's moving.
    turnability = [@turn_still, body.v.length / @spd_max].max
    effective_max = @turn_max * turnability * @turn_mod

    if turn != 0
      if body.w.abs < effective_max
        body.w += turn * @turn_accel ** seconds
      else
        body.w = turn * effective_max
      end
    else
      body.w *= @turn_decay ** seconds
    end
  end


  # Adjust movement vector to be more in line with boat's axis.
  # Because boats tend not to move sideways.
  def adjust_movement( seconds )
    dir = vec2(1,0).rotate(body.rot)

    # Ideal movement (correct direction, same speed as now)
    ideal = dir * body.v.length

    # How much of the old vector to keep
    blend = @dir_adjust ** seconds

    body.v = body.v * (1 - blend) + ideal * blend
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
