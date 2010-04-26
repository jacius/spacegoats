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
    :mass       => 40,
    :friction   => 0.5,
    :elasticity => 0.2,
    :verts      => [[-14,-7], [-15, 0], [-14, 7], [0, 6],
                    [ 11, 4], [ 14, 0], [ 11,-4], [0,-6]]
  }

  attr_accessor :turning_left,  :turning_right,
                :motor_fore,    :motor_back

  def setup
    self.action = :idle

    if opts[:angle]
      body.a = opts[:angle] * Math::PI/180.0
    end

    @turn_max   = 0.8           # max turn rate
    @turn_accel = 0.8           # acceleration when turning
    @turn_decay = 0.2           # spin slowdown when not turning (0 - 1)
    @turn_still = 0.4           # how well you can turn when not moving
    @turn_mod   = 1.3           # turnability modifier

    @spd_max    = 95            # max boat speed
    @spd_accel  = 30            # acceleration when motoring forwards
    @spd_back   = 15            # acceleration when motoring backwards
    @spd_decay  = 0.92          # slowdown when not motoring (0 - 1)

    # Tendency of the boat to change its movement vector to be in line
    # with the way it's pointing. (0 - 1)
    @dir_adjust = 0.2

    @turning_left  = false
    @turning_right = false
    @motor_fore    = false
    @motor_back    = false
  end


  def update( time_ms )
    seconds = time_ms * 0.001

    body.reset_forces

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
        body.t = turn * @turn_accel * body.m * 1000
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

    if body.v.length < @spd_max
      case motor
      when 1
        # motoring forward
        body.f = dir * motor * @spd_accel * body.m
      when -1
        # motoring backward
        body.f = dir * motor * @spd_accel * body.m
      else
        # idling
        body.v *= @spd_decay ** seconds
      end
    else
      # Slow down if going too fast
      body.v *= @spd_decay ** seconds
    end
  end

end
