require 'set'
require 'colored'

class Board
  attr_reader :pieces

  def initialize
    @pieces = []

    (0..2).each do |i|
      [0,2,4,6].each do |k|
        @pieces << Piece.new([i, k + (i.even? ? 1 : 0)], :blue, self)
      end
    end

    (5..7).each do |i|
      [0,2,4,6].each do |k|
        @pieces << Piece.new([i, k + (i.even? ? 1 : 0)], :red, self)
      end
    end

  end

  def [](arr)
    @pieces.find{|piece| piece.position == arr}
  end



  def display_board
    puts "   " + (0..7).map {|j| " #{j.to_i} "}.join
    (0..7).map do|i|
      row_array = (0..7).map do|j|
        piece = self[[i, j]]
        if piece.is_a?(Piece)
          piece.to_s
        else
          background = [i,j].inject(:+).even? ? "white" : "black"
          "   ".send("blue_on_#{background}")
        end
      end
      puts "#{i}  #{row_array.join}"
    end
  end



  def valid_move?(startpoint,endpoint,color)
    piece = self[startpoint]
    piece && piece.possible_moves.include?(endpoint) && piece.color == color

  end

  def move(startpoint,endpoint)
    self[startpoint].position = endpoint
  end

  def no_pieces(color)
    !@pieces.any?{|piece| piece.color == color}
  end

end

class Piece
  attr_reader :color
  attr_accessor :position

  def initialize(position,color,board)
    @position = position
    @color = color
    @board = board
  end

  def promotion_row
    color == :red ? 0 : 7
  end

  def possible_moves
    possible_shifts + possible_jumps
  end

  def shift_steps
    color == :red ? [[-1, 1],[-1, -1]] : [[1, 1],[1, -1]]
  end

  def to_s
    marker = " 0 "
    background = @position.inject(:+).even? ? "white" : "black"
    marker.send("#{color}_on_#{background}")
  end

  def possible_shifts
    shifts = Set.new
    y, x = @position
    shift_steps.each do |step|
      dy, dx = step[0], step[1]
      tentative = [y + dy, x + dx]
      shifts << tentative if @board[tentative].nil?
    end

    shifts.select{ |shift| shift.all?{ |coord| (0..7).include?(coord) } }
  end

  def possible_jumps
    jumps = Set.new
    y, x = @position
    shift_steps.each do |step|
      dy, dx = step[0], step[1]
      next if possible_shifts.include?([y + dy, x + dx])
      tentative = [y + 2 * dy, x + 2 * dx]
      jumps << tentative if @board[tentative].nil?
    end

    jumps.select{ |jump| jump.all?{ |coord| (0..7).include?(coord) } }
  end



end



class Game
  attr_reader :board

  def initialize
    @board = Board.new
    @red_player = Human.new(:red)
    @blue_player = Human.new(:blue)
  end

  def play
    player = @red_player
    until @board.no_pieces(:red) || @board.no_pieces(:blue)
      @board.display_board
      player = toggle_player(player)
      move_coords = player.get_coords
      until @board.valid_move?(move_coords[0], move_coords[1], player.color)
        puts "Invalid move: #{move_coords[0]} to #{move_coords[1]}"
        move_coords = player.get_coords
      end
      @board.move(move_coords[0],move_coords[1])
    end
  end

  def toggle_color(color)
    color == :red ? :blue : :red
  end

  def toggle_player(player)
    player == @red_player ? @blue_player : @red_player
  end

end


class Human
  attr_reader :color

  def initialize(color)
    @color = color
  end

  def get_coords
    puts "#{color.to_s.capitalize} Player's Turn"
    puts "Input command: (yx,yx)"
    gets.chomp.split(",").map { |coords| [coords[0].to_i, coords[1].to_i] }
  end

end

if __FILE__ == $0
  game = Game.new
  game.play
end