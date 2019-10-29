FactoryBot.define do
  factory :puzzle do
    user
    linear_measure { 1.5 }

    transient do
      picture_file { nil }
      ready? { false }
    end

    trait :with_picture do
      transient do
        picture_file { "pictures/mountain.jpg" }
      end
    end

    trait :ready do
      with_picture
      ready? { true }
    end

    after :create do|puzzle, options|
      extend ActiveJob::TestHelper
      if options.picture_file
        file = RSpec.configuration.fixture_path.join(options.picture_file)
        perform_enqueued_jobs do
          puzzle.picture.attach(io: file.open, filename: file.basename)
        end
        puzzle.reload
      end

      if options.ready?
        SetupJob.perform_now(puzzle, 1)
      end
    end
  end
end
