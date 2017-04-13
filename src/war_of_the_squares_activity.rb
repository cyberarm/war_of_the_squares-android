require 'ruboto/widget'
require 'main_game'

class WarOfTheSquaresActivity
  def onCreate(bundle)
    super
    # Can't instantiate Ruby class in Java, so create it here and pass it in
    puts "\\//\\//\\//\\"
    puts "Hello There."
    puts "\\//\\//\\//\\"
    Java.org.rubyclan.war_of_the_squares.WarOfTheSquaresActivity.mainGame = MainGame.new
    start_ruboto_activity "AndroidLauncher", {
      :java_class => Java.org.rubyclan.war_of_the_squares.android.AndroidLauncher
    }
  rescue Exception
    puts "E-E-E-E-E-E-E-E-E-E-E-E-E-E-E-E-E-E-E-E-E-E"
    puts "3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3-3"
    puts "Exception creating activity: #{$!}"
    puts $!.backtrace.join("\n")
    puts
    puts
  end
end
