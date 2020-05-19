require "rails_helper"

RSpec.describe FireRecord::Document do
  before do
    class City
      include FireRecord::Document
      include FireRecord::Collection
      attribute :name, :string

      has_many_docs :streets
    end

    class Street
      include FireRecord::Document
      belongs_to :city
      attribute :name, :string
    end
  end

  after do
    Object.send :remove_const, :City
    Object.send :remove_const, :Street
  end

  describe "plain model" do
    before do
      City.delete_all
    end

    describe "class" do
      subject { City }

      describe ".primary_key" do
        it "returns id" do
          expect(subject.primary_key).to eq "id"
        end
      end
    end

    describe "instance" do
      subject { City.new name: "Tokyo" }

      describe "#inspect" do
        it "returns attributes" do
          expect(subject.inspect).to match %r(^#<City .*>$)
          expect(subject.inspect).to match %r(\bid: nil\b)
          expect(subject.inspect).to match %r(\bname: "Tokyo")
        end
      end
    end
  end

  describe "belonged model" do
    let(:city) { City.create! id: "tky", name: "Tokyo" }

    before do
      city.streets.delete_all
    end

    describe "instance" do
      subject { city.streets.build name: "Eitai Street" }

      describe "#inspect" do
        it "returns attributes" do
          expect(subject.inspect).to match %r(^#<Street .*>$)
          expect(subject.inspect).to match %r(\bid: nil\b)
          expect(subject.inspect).to match %r(\bcity_id: "tky")
          expect(subject.inspect).to match %r(\bname: "Eitai Street")
        end
      end
    end
  end
end
