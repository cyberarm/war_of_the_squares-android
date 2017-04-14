class Base < Square
  @@locked = false
  attr_accessor :target

  def setup
    # setup the mind...
    @color = Color::BLACK if @friendly
    @color = Color::BLUE unless @friendly
    @target=nil
    @speed = 1

    @tick = 0
    @move_tick = 0
  end

  def draw
    super
    draw_line(@x+32, @y+32, @target.x+32, @target.y+32, Color::GREEN) if @target && @friendly
  end

  def update
    super
    @tick+=1
    @move_tick+=1

     if die? && !@@locked
      @@locked = true

      # if self.friendly
      #   $window.post_game.text = "#{Etc.getlogin} Lost!"
      #   $window.game_time.text = "Took #{Gosu.milliseconds/1000.0} seconds, and you took #{self.max_health} of #{self.max_health} damage (100%)"
      # else
      #   $window.post_game.text = "#{Etc.getlogin} Won!"
      #   friendly = Square.all.detect {|s| if s.friendly && s.is_a?(Base); true; end}
      #   $window.game_time.text = "Took #{Gosu.milliseconds/1000.0} seconds, and you took #{friendly.max_health-friendly.health} of #{friendly.max_health} damage (#{100-((friendly.health.to_f/friendly.max_health.to_f)*100).to_i}%)"
      # end
     end
    super

    if @tick >= 100
      spawn_square
      @tick = 0
    end

    @target = nil if @target && !@friendly && self.x.between?(@target.x-4, @target.x+4) && self.y.between?(@target.y-4, @target.y+4)

    move(@target.x, @target.y) if @target

    if @move_tick >= 4*60 && !@friendly
      unless @target
        @move_tick = 0
        @target   = Place.new(SecureRandom.random_number($window.width-70), SecureRandom.random_number($window.height-70))
      else
        @move_tick = 0
      end
    end
  end

  def spawn_square
    spawn = Square.all.detect {|square| if square.friendly != self.friendly; true; end}
    Warrior.new(self.x, self.y, @friendly) if spawn
  end
end
