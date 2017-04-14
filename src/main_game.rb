java_import com.badlogic.gdx.ApplicationAdapter
java_import com.badlogic.gdx.Gdx
java_import com.badlogic.gdx.graphics.GL20
java_import com.badlogic.gdx.graphics.OrthographicCamera
java_import com.badlogic.gdx.utils.Scaling
java_import com.badlogic.gdx.utils.viewport.ScalingViewport
java_import com.badlogic.gdx.utils.viewport.Viewport
java_import com.badlogic.gdx.graphics.g2d.BitmapFont
java_import com.badlogic.gdx.graphics.glutils.ShapeRenderer
java_import com.badlogic.gdx.graphics.g2d.SpriteBatch
java_import com.badlogic.gdx.graphics.Color

require "etc"
require "securerandom"
SecureRandom.random_number(100) # Prep, I guess?

# require_relative "lib/gui/font"
require_relative "lib/gui/drawing"
#
require_relative "lib/object"
require_relative "lib/objects/base"
require_relative "lib/objects/warrior"

# Your main game class. If you change the class name, make sure you update
# libgdx_activity.rb to specify the new game name.

class MainGame < ApplicationAdapter
  attr_reader :width, :height, :camera, :viewport, :batch, :font, :shape_renderer, :draw_queue
  attr_accessor :deaths

  def create
    $window = self
    @width  = Gdx.graphics.width
    @height = Gdx.graphics.height

    # Double start glitch compansation
    Square.all.clear
    Square.all_friendly.clear
    Square.all_hostile.clear

    @camera = OrthographicCamera.new(@width, @height)
    @camera.set_to_ortho(true, Gdx.graphics.width, Gdx.graphics.height)
    @viewport = ScalingViewport.new(Scaling.fit, 1920, 1080, @camera)
    @viewport.update(Gdx.graphics.getWidth, Gdx.graphics.getHeight, true)


    @draw_queue = []
    @batch = SpriteBatch.new
    @end_batch = SpriteBatch.new
    @font  = BitmapFont.new(true)
    @font.set_color(0,0,0, 0.9)
    @shape_renderer = ShapeRenderer.new

    @player = Base.new(100, 120, true)
    Base.new(@width-500, 250, false)

    @deaths = 0
    @last_collision_check_time = 0.0
    @activity_active = true
    @startgame_time = Time.now.to_f
    @endgame_text = nil
    @endgame_time_text = nil
  end

  def render
    Gdx.gl.glClearColor(1, 1, 1, 1)
    Gdx.gl.glClear(GL20.GL_COLOR_BUFFER_BIT)

    @camera.update
    @batch.setProjectionMatrix(@camera.combined)
    @end_batch.setProjectionMatrix(@camera.combined)
    @shape_renderer.setProjectionMatrix(@camera.combined)

    Gdx.gl.glEnable(GL20.GL_BLEND)
    Gdx.gl.glBlendFunc(GL20.GL_SRC_ALPHA,GL20.GL_ONE_MINUS_SRC_ALPHA)
    draw
    Gdx.gl.glDisable(GL20.GL_BLEND)

    @batch.begin
      text("FPS: #{Gdx.graphics.frames_per_second}", 10, 10)
      text("Objects: #{Square.all.count}", 10, 25)
      text("Deaths: #{@deaths}", 10, 40)
      text("Last Collision Time: #{@last_collision_check_time}", 10, 55)
    @batch.end
    draw_queue

    if @endgame_text
      @font.data.set_scale(4.0, 4.0)
      @endgame_status ? @font.set_color(0,1,0,1) : @font.set_color(1,0,0,1)
      @end_batch.begin
        text(@endgame_text, @width/2.5, @height/2.5, false, @end_batch)
        text(@endgame_time_text, @width/2.5, @height/2.5+55, false, @end_batch)
      @end_batch.end
      @font.data.set_scale(1.0, 1.0)
      @font.set_color(0,0,0, 0.9)
    end

    update if @activity_active
  end

  def resume
    @activity_active = true
  end

  def pause
    @activity_active = false
  end

  def dispose
    @batch.dispose
    @font.dispose
    @shape_renderer.dispose
  end

  def update
    handle_touch
    Square.all.each(&:update)
    collision_detection
    gameover?
  end

  def draw
    Square.all.each_slice(4) do |sub_array|
      @shape_renderer.begin(ShapeRenderer::ShapeType::Filled)
        sub_array.each(&:draw)
      @shape_renderer.end
    end
  end

  def draw_queue
    @draw_queue.each_slice(8) do |sub_array|
      @batch.begin
        sub_array.each(&:call)
      @batch.end
    end
    @draw_queue.clear
  end

  def collision_detection
    start = Time.now.to_f
    Square.all_friendly.product(Square.all_hostile) do |squareA, squareB|
      if (squareA.x - squareB.x).abs < 64 and (squareA.y - squareB.y).abs < 64
        squareA.hit
        squareB.hit
      end
    end

    @last_collision_check_time = Time.now.to_f-start
  end

  def gameover?
    if Square.all_hostile.size <= 0 && !@endgame_lock
      # Won!
      @endgame_lock = true
      @endgame_status = true
      @endgame_text = "You Won!"
      @endgame_time_text = "Took #{(Time.now.to_f-@startgame_time.to_f).round(2)} seconds".freeze
    elsif Square.all_friendly.size <= 0 && !@endgame_lock
      # Lost :(
      @endgame_lock = true
      @endgame_status = false
      @endgame_text = "You Lost!"
      @endgame_time_text = "Took #{(Time.now.to_f-@startgame_time.to_f).round(2)} seconds".freeze
    end
  end

  def handle_touch
    if Gdx.input.is_touched
      @player.target   = Square::Place.new
      @player.target.x = Gdx.input.x-32
      @player.target.y = Gdx.input.y-32
    end
  end

  def text(string = "", x = 0, y = 0, queue = false, batch = @batch)
    if queue
      obj = proc { @font.draw(batch, string, x, y) }
      @draw_queue.push(obj)
    else
      @font.draw(batch, string, x, y)
    end
  end

  def rect(x, y, width, height, color)
    @shape_renderer.color=color
    @shape_renderer.rect(x, y, width, height)
  end

  def line(x, y, x2, y2, color, width = 2)
    @shape_renderer.color=color
    @shape_renderer.rect_line(x, y, x2, y2, width)
  end

  def distance(x, y, x2, y2)
    Math.hypot(x2-x,y2-y)
  end
end
