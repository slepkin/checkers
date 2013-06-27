require 'set'
require 'colored'

class Board
  attr_reader :pieces

  def initialize
    @pieces = []
    # (0..2).each do |i|
    #   ()
    @pieces << Piece.new([3,1], :blue, self)
    @pieces << Piece.new([4,2], :red, self)
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



  def valid_move?(startpoint,endpoint)
    self[startpoint] && self[startpoint].possible_moves.include?(endpoint)
  end

  def move(startpoint,endpoint)
    self[startpoint].position = endpoint
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
      p tentative
      p @board[tentative].nil?
      shifts << tentative if @board[tentative].nil?
    end

    shifts.select{|shift| shift.all?{ |coord| (0..7).include?(coord) } }
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

    jumps.select{|jump| jump.all?{ |coord| (0..7).include?(coord) } }
  end

end

