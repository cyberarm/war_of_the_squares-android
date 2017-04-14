class Square
  Place = Struct.new(:x, :y)
  java_import com.badlogic.gdx.graphics.Color
  include Drawing

  attr_accessor :x, :y, :z, :alpha, :color, :health, :max_health, :friendly
  @@objects = []

  def initialize(x = 0, y = 0, friendly = false)
    @x = x
    @y = y
    @z = 0
    @alpha = 255
    @color = Color::BLACK
    @health = 250
    @max_health = 250
    @friendly = friendly

    @@objects << self

    setup if defined?(self.setup)
  end

  def draw
    fill_rect(@x, @y, 64, 64, @color)

    # health
    fill_rect(@x, @y-36, (@max_health/100.0*64), 18, Color::BLACK)
    fill_rect(@x, @y-36, (@health/100.0*64), 18, Color::GREEN) if @friendly
    fill_rect(@x, @y-36, (@health/100.0*64), 18, Color::RED) unless @friendly
    # $window.text("#{@health}/#{@max_health}", self.x, self.y)
  end

  def update
    die?
  end

  def hit
    @health-=1
  end

  def die?
    if @health <= 0
      @@objects.delete(self)
      true
    else
      false
    end
  end

  def move(x, y)
    # http://stackoverflow.com/a/2625107/4664585
    dir_x = x - self.x
    dir_y = y - self.y

    hyp = Math.sqrt(dir_x*dir_x + dir_y*dir_y)
    dir_x /= hyp
    dir_y /= hyp

    self.x += dir_x*@speed
    self.y += dir_y*@speed
  end

  def self.all
    @@objects
  end
end
