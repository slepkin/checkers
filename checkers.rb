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
    restrict = (any_jumps?(color) ? :jumps : nil)
    move_type = move_type(startpoint, endpoint)
    piece = self[startpoint]
    piece && \
    piece.possible_moves(restrict).include?(endpoint) && \
    piece.color == color

  end

  def move_and_kill(startpoint, endpoint)
    y1, x1 = startpoint[0], startpoint[1]
    y2, x2 = endpoint[0], endpoint[1]
    self[startpoint].position = endpoint
    victim = self[[(y1 + y2) / 2, (x1 + x2) / 2]] if (y1 - y2).abs == 2
    @pieces.delete(victim) unless victim.nil?
  end

  def move_type(startpoint, endpoint)
    (startpoint[0] - endpoint[0]).abs == 1 ? :move : :shift
  end

  def any_jumps?(color)
    all_pieces(color).any? { |piece| piece.possible_moves(:jumps)[0] }
  end

  def all_pieces(color)
    @pieces.select{|piece| piece.color == color}
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

  # def possible_moves
#     possible_shifts + possible_jumps
#   end

  def possible_moves(restrict = nil)
    moves = []
    y, x = @position
    shift_steps.each do |step|
      dy, dx = step
      if @board[[y + dy, x + dx]].nil?
        moves << [y + dy, x + dx] unless restrict == :jumps
        #p "Added #{[y + dy, x + dx]}" #debug
      elsif @board[[y + dy, x + dx]].color == @color
        next
      else
        moves << [y + 2 * dy, x + 2 * dx]
        #p "Added #{[y + 2 * dy, x + 2 * dx]}" #debug
      end
    end
    moves
  end


  def shift_steps
    color == :red ? [[-1, 1],[-1, -1]] : [[1, 1],[1, -1]]
  end

  def to_s
    marker = " 0 "
    background = @position.inject(:+).even? ? "white" : "black"
    marker.send("#{color}_on_#{background}")
  end

  # def possible_shifts
  #   shifts = Set.new
  #   y, x = @position
  #   shift_steps.each do |step|
  #     dy, dx = step[0], step[1]
  #     tentative = [y + dy, x + dx]
  #     shifts << tentative if @board[tentative].nil?
  #   end
  #
  #   shifts.select{ |shift| shift.all?{ |coord| (0..7).include?(coord) } }
  # end
  #
  # def possible_jumps
  #   jumps = Set.new
  #   y, x = @position
  #   shift_steps.each do |step|
  #     dy, dx = step[0], step[1]
  #     tentative = [y + 2 * dy, x + 2 * dx]
  #     between = [y + dy, x + dx]
  #     next if possible_shifts.include?(between)
  #     jumps << tentative if @board[tentative].nil? && @board[between].color
  #   end
  #
  #   jumps.select{ |jump| jump.all?{ |coord| (0..7).include?(coord) } }
  # end



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
    until @board.all_pieces(:red).empty? || @board.all_pieces(:blue).empty?
      @board.display_board
      player = toggle_player(player)
      move_coords = player.get_coords
      until @board.valid_move?(move_coords[0], move_coords[1], player.color)
        puts "Invalid move: #{move_coords[0]} to #{move_coords[1]}"
        move_coords = player.get_coords
      end
      @board.move_and_kill(move_coords[0],move_coords[1])
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