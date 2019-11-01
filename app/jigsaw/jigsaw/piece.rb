require 'matrix'

class Jigsaw::Piece < Struct.new(:number, :points, :neighbors)
  class << self
    def from_facet fac
      new(
        fac.number,
        fac.geometry.map { |p| p&.to_a },
        fac.edges
          .select { |e| e.mate.facet }
          .map { |e| e.mate.facet.number }
          .sort.uniq
      )
    end
  end

  def boundary
    @boundary ||=
      begin
        inf = Float::INFINITY
        points.compact.reduce([Vector[inf, inf], Vector[-inf, -inf]]) do |acc, pt|
          if pt
            [
              Vector[[acc[0][0], pt[0]].min, [acc[0][1], pt[1]].min],
              Vector[[acc[1][0], pt[0]].max, [acc[1][1], pt[1]].max]
            ]
          else
            acc
          end
        end
      end
  end

  def center
    boundary.inject(:+) / 2
  end
end
