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
end
