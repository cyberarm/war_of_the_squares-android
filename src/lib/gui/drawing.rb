module Drawing
  def fill_rect(x, y, width, height, color)
    $window.rect(x,y, width,height, color)
  end

  def draw_line(x, y, x2, y2, color)
    $window.line(x,y, x2,y2, color)
  end
end
