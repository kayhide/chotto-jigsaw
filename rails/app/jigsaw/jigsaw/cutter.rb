class Jigsaw::Cutter
  attr_reader :count, :linear_measure
  attr_accessor :width, :height, :fluctuation, :irregularity

  def initialize
    @width = 1
    @height = 1
    @fluctuation = 0
    @irregularity = 0
    @random = Random.new
    @count = 1
    @linear_measure = 1
  end

  def cut
    facs = create_facets
    facs.flatten.each_with_index.map do |fac, i|
      fac.number = i
    end
    facs.each(&method(:create_curves))
    facs.map(&Jigsaw::Piece.method(:from_facet))
  end

  def create_curves fac
    fac.edges.each do |he|
      unless he.curve
        he.set_curve create_curve(he)
      end
    end
  end

  class << self
    def create curve = :standard, layout = :grid
      cutter = self.new
      cutter.extend self.const_get("#{layout}_layout".camelize)
      cutter.extend self.const_get("#{curve}_curve".camelize)
    end
  end
end
