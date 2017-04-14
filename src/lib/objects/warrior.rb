class Warrior < Square
  def setup
    self.health = 100
    self.max_health = 100
    self.color = Color::GREEN if   @friendly
    self.color = Color::RED unless @friendly
    @speed = 1
    @target=nil
    @target_tick=0
    @retarget_tick=0
    @target_distance=nil
  end

  def draw
    fill_rect(@x-2, @y-2, 68, 68, Color::BLACK)
    fill_rect(@x-64, @y-64, 192, 192, Color.new(0.1,0.1,0.1, 0.1))

    draw_line(@x+32, @y+32, @target.x+32, @target.y+32, Color::YELLOW) if @target && @friendly
    draw_line(@x+32, @y+32, @target.x+32, @target.y+32, Color::BLACK) if @target && !@friendly
    super
  end

  def update
    super
    targets = []
    if @retarget_tick > 4
      @retarget_tick = 0
      targets = Square.all.find_all do |square|
        if square.friendly != self.friendly
          if square.x.between?(self.x-64, self.x+192)
            if square.y.between?(self.y-64, self.y+192)
              true
            end
          end
        end
      end
    end
    @retarget_tick+=1

    target = nil
    distance= 172
    targets.each do |_target|
      _distance = $window.distance(self.x, self.y, _target.x, _target.y)
      if _distance < distance
        target = _target
        distance = _distance
      end
    end

    if @target == nil
      @target_tick=0
      @target_distance=nil

      base = Square.all.detect do |square|
        if square.friendly != self.friendly && square.is_a?(Base)
          true
        end
      end

      # No enemie base
      unless base
        base = Square.all.detect do |square|
          if square.friendly != self.friendly
            true
          end
        end
      end

      # No enemies
      unless base
        base = Place.new(rand($window.width-70), rand($window.height-70))
      end

      target = base
      @target = target
      @target_distance = $window.distance(self.x, self.y, @target.x, @target.y) if @target
      @target_distance = nil unless @target
    else
      if target
        @target = target
        @target_distance = $window.distance(self.x, self.y, @target.x, @target.y)
      end
    end

    if @target
      @target_tick+=1
      move(@target.x, @target.y)
    end

    expiring_target
  end

  def expiring_target
    if @target_tick > 60
      if $window.distance(self.x, self.y, @target.x, @target.y) < @target_distance
        @target_distance = $window.distance(self.x, self.y, @target.x, @target.y)
      else
        @target = nil
      end
    end
  end
end
