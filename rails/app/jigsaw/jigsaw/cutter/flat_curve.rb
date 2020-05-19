module Jigsaw::Cutter::FlatCurve
  def create_curve he
    [he.point, nil, nil, he.next.point]
  end
end
