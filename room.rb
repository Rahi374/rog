=begin

Problems
========

Generate 100 rooms

1 initial branch ("path")
Connections up, down, left, right
Corresponding back connections

Multiple secondary branches

Possible creation steps
=======================

# Create initial branch (will not die)
	
# Continue intial branch
# Continue or kill secondary branch

# Create offshoot
# Create secondary branch

=end

class Rooms
	attr_accessor :num, :rooms
	
	def initialize
		@rooms = {}
		@num = 0
	end
	
	def create_room width=nil, height=nil
		width ||= rand(540)+100
		height ||= rand(380)+100
		@rooms[@num] = {
			:width => width,
			:height => height,
			:doors => {},
			:num => @num,
		}
		@num += 1
		return @rooms[@num-1]
	end
	
	def add_connection room1, room2, side=nil
		# Pick side
		side ||= {0 => :top, 1 => :right, 2 => :bottom, 3 => :left}[rand(4)]
		
		case side
			when :top
				x = rand(room1[:width]-100)
				x2 = rand(room2[:width]-100)
				door1 = [x,0,x+100,2]
				door2 = [x2,room2[:height]-2,x2+100,room2[:height]]
				spawn1 = [door2[0]+50-10,room2[:height]-30]
				spawn2 = [door1[0]+50-10,10]
				room1[:doors][room2[:num]] = [door1,spawn1]
				room2[:doors][room1[:num]] = [door2,spawn2]
			when :right
			
			when :bottom
				x = rand(room1[:width]-100)
				x2 = rand(room2[:width]-100)
				door1 = [x,room1[:height]-2,x+100,room1[:height]]
				door2 = [x2,0,x2+100,2]
				spawn1 = [door2[0]+50-10,10]
				spawn2 = [door1[0]+50-10,room1[:height]-30]
				room1[:doors][room2[:num]] = [door1,spawn1]
				room2[:doors][room1[:num]] = [door2,spawn2]
			when :left
		end
	end
	
	def export
		return @rooms
	end
end

def create_dungeon
	dungeon = Rooms.new
	20.times do |i|
		dungeon.create_room
		if i != 0
			dungeon.add_connection(dungeon.rooms[dungeon.num-2],dungeon.rooms[dungeon.num-1], :bottom)
		end
	end
	dungeon.export
end

if __FILE__ == $0
	require 'pp'
	pp create_dungeon
end