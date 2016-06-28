class Setup < State
  class NameInput < Text
    class FlashingLine < Box
      def initialize x, y, obj
	super :width => 1, :height => 20, :x => x, :y => y
	@draw = 0
	@obj = obj
      end
      
      def update
	@draw += 1
	@draw = 0 if @draw >= 30
	@x = @obj.x + @obj.width
      end
      
      def draw
	super if @draw >= 10
      end
    end
    
    def initialize
      super :text => "", :x => 200, :y => 100
      
      t = Text.new :text => "Name: ", :y => @y
      t.x = @x-t.width
      FlashingLine.new @x, @y+5, self
      
      event(KeyPressed) do |ev|
	approved = {:comma => ",", :minus => "-", :period => ".", :slash => "/", :equals => "=", :quote => "'", :left_bracket => "[", :right_bracket => "]", :semicolon => ";", :backslash => "\\", :backquote => "`", :number_0 => "0", :number_1 => "1", :number_2 => "2", :number_3 => "3", :number_4 => "4", :number_5 => "5", :number_6 => "6", :number_7 => "7", :number_8 => "8", :number_9 => "9"}
	upcase = {"1" => "!", "2" => "@", "3" => "#", "4" => "$", "5" => "%", "6" => "^", "7" => "&", "8" => "*", "9" => "(", "0" => ")", "-" => "_", "=" => "+", "[" => "{", "]" => "}", ";" => ":", "'" => "\"", "," => "<", "." => ">", "/" => "?", "\\" => "|", "`" => "~"}
	key = ev.key.to_s
	key = approved[ev.key] if approved.include?(ev.key)
	key = key[-1] if key[0..-2] == "number_"
	if ev.modifiers.include?(:left_shift) or ev.modifiers.include?(:right_shift)
	  key.upcase!
	  key = upcase[key] if upcase.include?(key)
	end
	unless ev.key == :backspace or key.length > 1
	  @text += key
	end
	@text += " " if ev.key == :space
	@text = @text[0..-2] if ev.key == :backspace

	rerender_text
      end
    end
  end
  
  class SlidyThing < Box
    def initialize slider
      height = slider.height+4
      @start_x = slider.x-height/2
      super :x => @start_x+255, :y => slider.y-2, :height => height, :width => height
      
      @slider = slider
      @pressed = false
      
      mouse_pressed_on do
	@pressed = true
      end
      mouse_release do
	@pressed = false
      end
      mouse_motion do |ev|
	if @pressed
	  @x += ev.rel[0]
	  @x = @slider.x-@width/2 if @x < @slider.x-@width/2
	  @x = @slider.x+@slider.width-@width/2 if @x > @slider.x+@slider.width-@width/2
	  update_val
	end
      end
    end
    
    def update_val
      @slider.val = @x-@start_x
    end
  end
  
  class Slider < Box
    def initialize x, y
      super :x => x, :y => y, :width => 255, :height => 10, :color => [0,0,0]
      @surface.draw_box([0,0],[@width-2,@height-2],[255,255,255])
      SlidyThing.new self
    end
    
    def val= a
      method(:color=).call [a,0,0]
    end
    
    def color= opt
      super opt
      @surface.draw_box([0,0],[@width-2,@height-2],[255,255,255])
    end
  end
  
  class RGB < Box
    def initialize red, green, blue
      super :x => 450, :y => 165, :width => 100, :height => 100
      @red = red
      @green = green
      @blue = blue
    end
    
    def update
      method(:color=).call [@red.color[0],@green.color[1],@blue.color[2]]
    end
  end
  
  class StartButton < Drawable
    def initialize name, rgb
      surface = Rubygame::Surface.new [80, 30]
      super :y => 350, :width => surface.width, :height => surface.height, :surface => surface
      center_x
      @surface.draw_box([1,1],[@width-2,@height-2],[255,255,255])
      @orig_surface = @surface
      @hover_surface = Rubygame::Surface.new [@width, @height]
      @hover_surface.fill [255,255,255]
      @text = Text.new :text => "Start", :x => @x+20, :y => @y
      @error = Text.new :text => " ", :x => 200, :y => 130, :color => [255,0,0], :size => 16
      def @error.show_err err
	method(:text=).call(err)
	defer(lambda { method(:text=).call(" ") }, 60)
      end
      
      @name = name
      @rgb = rgb
      
      mouse_hovering_over do
	@surface = @hover_surface
	@text.color = [0,0,0]
      end
      
      mouse_not_hovering_over do
	@surface = @orig_surface
	@text.color = [255,255,255]
      end
      
      start_game = Proc.new do
	if @name.text.strip.empty?
	  @error.show_err "Name can't be blank"
	elsif @name.text.length > 25
	  @error.show_err "Name can't be longer than 25 characters"
	else
	  @@game.switch_state InGame.new @name.text, @rgb.color
	end
      end
      
      mouse_pressed_on { start_game.call }
      key_press(:return) { start_game.call }
    end
  end
  
  def setup
    name = NameInput.new
    Text.new :x => 135, :y => 150, :text => "Color:"
    red = Slider.new 135, 190
    green = Slider.new 135, 210
    def green.val= a
      method(:color=).call [0,a,0]
    end
    blue = Slider.new 135, 230
    def blue.val= a
      method(:color=).call [0,0,a]
    end
    [red,green,blue].each do |obj|
      obj.val = 255
    end
    rgb = RGB.new red, green, blue
    StartButton.new name, rgb
  end
end
