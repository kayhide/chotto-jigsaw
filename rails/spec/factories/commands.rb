FactoryBot.define do
  factory :command do
    user { nil }
    game { nil }
    type { "" }
    piece_id { 1 }
  end
end
