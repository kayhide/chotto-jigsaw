require 'matrix'

class Jigsaw::HalfEdge
  class <<self
    def create_loop count = 1
      head = self.create
      he = head
      (1...count).each do
        ne = self.create
        he.set_next ne
        he = ne
      end
      he.set_next head
      head
    end

    def create
      he = self.new
      he.mate = self.new
      he.mate.mate = he
      he.next = he.mate
      he.mate.next = he
      he
    end
  end

  attr_accessor :next, :mate, :point, :curve, :facet, :parity

  def initialize
    @point = Vector[0.0, 0.0]
    @curve = nil
    @facet = nil
    @parity = nil
  end

  def prev
    he = @mate
    while he.next != self
      he = he.next.mate
    end
    he
  end

  def each_on_loop
    yield self
    he = @next
    while he != self
      yield he
      he = he.next
    end
  end

  def center
    (@point + @next.point) * 0.5
  end

  def set_point pt
    @point = pt
    he = @mate.next
    while he != self
      he.point = pt
      he = he.mate.next
    end
  end

  def set_next he
    @next = he
    he.mate.next = @mate
  end

  def set_mate he
    unless @mate == he
      if @mate.prev != he.prev
        @mate.prev.next = he.mate.next
      end
      if he.mate.prev != prev
        he.mate.prev.next = @mate.next
      end
      @mate = he
      he.mate = self
    end
  end

  def set_facet facet
    each_on_loop do |he|
      he.facet = facet
    end
  end

  def set_curve pts
    @curve = pts
    @mate.curve = pts.reverse
  end

  def set_parity parity
    @parity = parity
    @mate.parity = -parity
  end
end
