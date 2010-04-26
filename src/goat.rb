require 'actor'

class Goat < Actor

  has_behaviors :updatable, :animated, :audible,
                :collidable => { :shape => :circle, :radius => 10}

  def setup
    # Randomize the animation a bit
    animated.frame_update_time = 800 + rand(50)
    animated.frame_time = rand(400)
    rand(10).times do
      animated.next_frame()
    end
  end


end
