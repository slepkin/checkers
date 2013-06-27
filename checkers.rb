require 'set'
require 'colored'

class Board
  attr_reader :pieces

  def initialize(pieces = true)
    @pieces = []
    if pieces == true
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



  def perform_shift(color, startpoint, endpoint)
    piece = self[startpoint]
    unless on_board?(startpoint) && on_board?(endpoint)
      raise InvalidMoveError.new "That coordinate is not on the board."
    end
    unless piece.reachable_shifts.include?(endpoint)
      raise InvalidMoveError.new "That piece cannot reach there."
    end
    unless self[endpoint].nil?
      raise InvalidMoveError.new "That coordinate is occupied."
    end
    unless piece.color == color
      raise InvalidMoveError.new "That is not your color."
    end
    piece.position = endpoint
  end

  def perform_jump(color, startpoint, endpoint)
    piece = self[startpoint]
    y1, x1 = startpoint[0], startpoint[1]
    y2, x2 = endpoint[0], endpoint[1]
    unless on_board?(startpoint) && on_board?(endpoint)
      raise InvalidMoveError.new "That coordinate is not on the board."
    end
    unless piece.reachable_jumps.include?(endpoint)
      raise InvalidMoveError.new "That piece cannot jump there."
    end
    unless self[endpoint].nil?
      raise InvalidMoveError.new "That coordinate is occupied."
    end
    unless piece.color == color
      raise InvalidMoveError.new "That is not your color."
    end
    victim = self[[(y1 + y2) / 2, (x1 + x2) / 2]]
    piece.position = endpoint
    @pieces.delete(victim)
  end

  def perform_moves!(color, *seq)
    seq.each_with_index do |startpoint, i|

      break if i == seq.length - 1
      endpoint = seq[i+1]
      if (startpoint[0] - endpoint[0]).abs == 1
        raise InvalidMoveError.new "You may only shift." if seq.length > 2
        perform_shift(color, startpoint, endpoint)
      else
        p "Color #{color}, start #{startpoint}, end #{endpoint}"
        perform_jump(color, startpoint, endpoint)
      end
    end
    promote(seq[-1])
  end

  def valid_move_seq?(color, *seq)
    temp_board = dup
    begin
      temp_board.perform_moves!(color, *seq)
    rescue InvalidMoveError => e
      puts e.message
      return false
    end
    true
  end


  def all_pieces(color)
    @pieces.select{|piece| piece.color == color}
  end

  def promote(coords)
    if self[coords] && self[coords].promotion_row == coords[0]
      promotee = @pieces.find{|piece| piece.position == coords}
      color = promotee.color
      @pieces.delete(promotee)
      @pieces << King.new(coords, color, self)
      puts "#{color.to_s.capitalize} Soldier promoted!"
    end
  end

  def on_board?(coord)
    coord.all? { |x| (0..7).include?(x) }
  end

  def dup
    temp_board = Board.new(false)
    @pieces.each do |piece|
      position = piece.position
      color = piece.color
      piece_type = piece.class
      temp_board.pieces << piece_type.new(position, color, temp_board)
    end
    temp_board
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


  def shift_steps
    color == :red ? [[-1, 1],[-1, -1]] : [[1, 1],[1, -1]]
  end

  def to_s
    marker = " 0 "
    background = @position.inject(:+).even? ? "white" : "black"
    marker.send("#{color}_on_#{background}")
  end


  def reachable_shifts
    shifts = []
    shift_steps.map do |step|
      shifts << [@position[0] + step[0], @position[1] + step[1]]
    end

    shifts
  end

  def reachable_jumps
    jumps = []
    y, x = @position
    p "I am a #{self.class}"
    p "with steps #{shift_steps}"
    self.shift_steps.each do |step|
      dy, dx = step[0], step[1]
      tentative = [y + 2 * dy, x + 2 * dx]
      between = [y + dy, x + dx]
      p "Thinking about jumping over #{between} to #{tentative}"
      p "Between is a : #{@board[between].class}"
      next if @board[between].nil? || @board[between].color == color
      jumps << tentative
    end

    jumps
  end

end

class King < Piece

  def shift_steps
    [[-1, 1], [-1, -1], [1, 1], [1, -1]]
  end

  def to_s
    marker = " K "
    background = @position.inject(:+).even? ? "white" : "black"
    marker.send("#{color}_on_#{background}")
  end

end



class Game
  attr_accessor :board

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
      until @board.valid_move_seq?(player.color, *move_coords)
        move_coords = player.get_coords
      end
      @board.perform_moves!(player.color, *move_coords)
    end
    puts "#{player.color.upcase} WINS!"
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
    puts "Input command."
    puts "Ex: 'yx,yx' for a shift, or 'yx,yx,yx,...' for a jump sequence."
    gets.chomp.split(",").map { |coords| [coords[0].to_i, coords[1].to_i] }
  end

end

class InvalidMoveError < StandardError
end

if __FILE__ == $0
  game = Game.new
  game.play




end