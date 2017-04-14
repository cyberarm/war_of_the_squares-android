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
	attr_reader :width, :height, :camera, :viewport, :batch, :font, :shape_renderer

	def create
		$window = self
		@width  = Gdx.graphics.width
		@height = Gdx.graphics.height

		@camera = OrthographicCamera.new(@width, @height)
    @camera.set_to_ortho(true, Gdx.graphics.width, Gdx.graphics.height)
		@viewport = ScalingViewport.new(Scaling.fit, 1920, 1080, @camera)
		@viewport.update(Gdx.graphics.getWidth, Gdx.graphics.getHeight, true)


		@batch = SpriteBatch.new
		@font  = BitmapFont.new(true)
		@font.set_color(0,0,0, 0.9)
		@shape_renderer = ShapeRenderer.new

		@player = Base.new(100, 120, true)
		Base.new(@width-500, 250, false)
	end

	def render
		Gdx.gl.glClearColor(1, 1, 1, 1)
		Gdx.gl.glClear(GL20.GL_COLOR_BUFFER_BIT)

		@camera.update
		@batch.setProjectionMatrix(@camera.combined)
		@shape_renderer.setProjectionMatrix(@camera.combined)

		@batch.begin
			text("FPS: #{Gdx.graphics.frames_per_second}", 10, 10)
			text("Objects: #{Square.all.count}", 10, 25)
		@batch.end

		Gdx.gl.glEnable(GL20.GL_BLEND)
		Gdx.gl.glBlendFunc(GL20.GL_SRC_ALPHA,GL20.GL_ONE_MINUS_SRC_ALPHA)
		@shape_renderer.begin(ShapeRenderer::ShapeType::Filled)
			draw
		@shape_renderer.end
		Gdx.gl.glDisable(GL20.GL_BLEND)

		update
	end

	def dispose
		@batch.dispose
		@font.dispose
		@shape_renderer.dispose
	end

	def update
		handle_touch

		Square.all.each do |squareA|
			squareA.update
			Square.all.each do |squareB|
				if squareA.friendly != squareB.friendly
					if squareA.x.between?(squareB.x-4, squareB.x+68)
						if squareA.y.between?(squareB.y-4, squareB.y+68)
							squareA.hit
							squareB.hit
						end
					end
				end
			end
		end
	end

	def draw
		Square.all.each(&:draw)
	end

	def handle_touch
		if Gdx.input.just_touched
		  @player.target   = Square::Place.new
		  @player.target.x = Gdx.input.x-32
		  @player.target.y = Gdx.input.y-32
		end
	end

	def text(string = "", x = 0, y = 0)
		@font.draw(@batch, string, x, y)
	end

	def rect(x, y, width, height, color)
		@shape_renderer.color=color
		@shape_renderer.rect(x, y, width, height)
	end

	def line(x, y, x2, y2, color)
		@shape_renderer.color=color
		@shape_renderer.line(x, y, x2, y2)
	end

	def distance(x, y, x2, y2)
		Math.hypot(x2-x,y2-y)
	end
end
