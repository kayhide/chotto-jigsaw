require 'matrix'

module Jigsaw::Cutter::GridLayout
  attr_accessor :nx, :ny

  def initialize
    @nx = 1
    @ny = 1
  end

  def create_facets
    @count = @nx * @ny
    w = @width.to_f / @nx
    h = @height.to_f / @ny
    @linear_measure = Math.sqrt(w * w + h * h)

    facs = []
    (0...@ny).each do |y|
      facs << []
      (0...@nx).each do |x|
        p = Jigsaw::Facet.new
        p.edge = Jigsaw::HalfEdge.create_loop(4)
        p.edge.set_facet p
        facs[y] << p
      end
    end

    (0...@ny).each do |y|
      (0...@nx).each do |x|
        if x < @nx - 1
          facs[y][x].edge.next.next.set_mate facs[y][x + 1].edge
        end
        if y > 0
          facs[y][x].edge.next.next.next.set_mate facs[y - 1][x].edge.next
        end
        if x > 0
          facs[y][x].edge.set_mate facs[y][x - 1].edge.next.next
        end
        if y < @ny - 1
          facs[y][x].edge.next.set_mate facs[y + 1][x].edge.next.next.next
        end

        parity = ((x + y) % 2) * 2 - 1
        facs[y][x].edges.each do |he|
          parity *= -1
          unless he.parity
            he.set_parity((@random.rand() < @irregularity) ? parity : -parity)
          end
        end
      end
    end

    create_points facs
    facs.flatten
  end

  def create_points facs
    (0..@ny).each do |y|
      (0..@nx).each do |x|
        dx = (x == 0 or x == @nx) ? 0.0 : (@fluctuation * 0.5 * (@random.rand * 2 - 1))
        dy = (y == 0 or y == @ny) ? 0.0 : (@fluctuation * 0.5 * (@random.rand * 2 - 1))
        pos = Vector[(x + dx) * @width / @nx.to_f, (y + dy) * @height / @ny.to_f]

        if x == @nx and y == @ny
          facs[y - 1][x - 1].edge.next.next.set_point(pos)
        elsif x == @nx
          facs[y][x - 1].edge.next.next.next.set_point(pos)
        elsif y == @ny
          facs[y - 1][x].edge.next.set_point(pos)
        else
          facs[y][x].edge.set_point(pos)
        end
      end
    end
  end
end
