class Jigsaw::Facet
  attr_accessor :number, :edge

  def edges
    hes = []
    @edge.each_on_loop do |he|
      hes << he
    end
    hes
  end

  def geometry
    [@edge.curve.first] + self.edges.map(&:curve).each_with_object(1).map(&:drop).inject(&:+)
  end
end
