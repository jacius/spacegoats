

# Represents the wind speed and direction in the world.
# Wind speed and direction varies over time based on some math.
# 
class Wind

  DEG_TO_RAD = Math::PI/180

  # options is a hash array with any of these options:
  # 
  # :dir::     Base wind direction (degrees clockwise from east).
  # :var_dir:: How much the wind direction varies over time (degrees).
  # :spd::     Base wind speed (km/s).
  # :var_spd:: How much the wind speed varies over time (km/s).
  # :flux::    Modifier for how fast the wind fluctuates.
  # :start::   The initial time for wind calculation. Default: now.
  # 
  def initialize( options={} )
    options ||= {}
    @dir     = options[:dir]     || 0.0
    @var_dir = options[:var_dir] || 0.0
    @spd     = options[:spd]     || 5.0
    @var_spd = options[:var_spd] || 0.0
    @flux    = options[:flux]    || 1.0
    @start   = (options[:start]  || Time.now).to_f
  end


  # Returns the wind at the given time (default now) as [x,y].
  def now( time=Time.now )
    t = (time - @start).to_f * 0.001 * @flux
    d = dir_now(t) * DEG_TO_RAD
    s = spd_now(t)
    return [Math.cos(d)*s, Math.sin(d)*s]
  end


  private

  def dir_now( t )
    i = 1.8 * Math.sin(t) * Math.sin(t*3) * Math.sin(t*4) * Math.cos(t*10)
    return @dir + (@var_dir * i)
  end

  def spd_now( t )
    i = 0.8 * Math.sin(t) * Math.sin(t*7) + 0.2 * Math.sin(t*15)
    return [0, @spd + (@var_spd * i)].max
  end


end
