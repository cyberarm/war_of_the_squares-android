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
    @enemy_list = @friendly ? Square.all_hostile : Square.all_friendly
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
    updater
  end

  def updater
    targets = @enemy_list.select do |square|
      if (square.x - self.x).abs < 192 and (square.y - self.y).abs < 192
        true
      end
    end

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
      @target_distance=nil

      base = @enemy_list.detect do |square|
        if square.is_a?(Base)
          true
        end
      end

      # No enemie base
      unless base
        base = @enemy_list.detect do |square|
          true
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
      if @target_distance && $window.distance(self.x, self.y, @target.x, @target.y) < @target_distance
        @target_distance = $window.distance(self.x, self.y, @target.x, @target.y)
      else
        @target = nil
        @target_tick=0
      end
    end
  end
end
