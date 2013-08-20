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
    self.shift_steps.each do |step|
      dy, dx = step[0], step[1]
      tentative = [y + 2 * dy, x + 2 * dx]
      between = [y + dy, x + dx]
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