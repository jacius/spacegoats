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
    :mass       => 200,
    :friction   => 0.4,
    :elasticity => 0.2,
    :verts      => [[-5,-15], [-5, 15],
                    [ 5, 15], [ 5,-15]]
  }

  def setup
    self.action = :idle
  end

end
