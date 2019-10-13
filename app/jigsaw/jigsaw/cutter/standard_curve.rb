module Jigsaw::Cutter::StandardCurve
  def create_curve he
    pt0 = he.point
    pt1 = he.next.point
    v1 = (pt1 - pt0) * 0.5

    mtx = Matrix.rotation_2d(he.parity * Math::PI * 2 / 3)
    v2 = mtx * v1

    points = []
    points << pt0
    if he.mate.facet
      if adv = adverse_edge_of(he)
        points << pt0 + (pt1 - adv.mate.point) * 0.5 * 0.2
      else
        points << pt0 + v1 * 0.2
      end
      points << pt0 + v1
      points << pt0 + v1 + v2 * 0.5
      points << pt0 + v1 + v2
      points << pt0 + v1 * 2 + v2
      points << pt0 + v1 * 1.5 + v2 * 0.5
      points << pt0 + v1
      if adv = adverse_edge_of(he.mate)
        points << pt1 - (adv.mate.point - pt0) * 0.5 * 0.2
      else
        points << pt1 - v1 * 0.2
      end
      points << pt1
    else
      points << nil
      points << nil
      points << pt1
    end
    points
  end

  def adverse_edge_of he
    if 4.times.inject(he){|memo| memo = memo.mate.next} == he
      2.times.inject(he){|memo| memo = memo.mate.next}
    else
      nil
    end
  end

end

class Matrix
  class <<self
    def rotation_2d rad
      Matrix[[Math.cos(rad),-Math.sin(rad)],
             [Math.sin(rad), Math.cos(rad)]]
    end
  end
end
