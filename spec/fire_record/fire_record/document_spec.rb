require "rails_helper"

RSpec.describe FireRecord::Document do
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

  describe "plain model" do
    before do
      City.delete_all
    end

    describe "class" do
      subject { City }

      describe ".scope" do
        it "returns a scope" do
          expect(subject.scope.path).to be_end_with "cities"
        end
      end

      describe ".create!" do
        it "adds a record to the collection" do
          expect {
            subject.create! name: "Tokyo"
          }.to change { subject.all.count }.by(1)
        end
      end

      describe ".find" do
        it "finds a record" do
          tokyo = subject.create! id: "tky", name: "Tokyo"
          expect(subject.find("tky")).to eq tokyo
        end
      end

      describe ".all" do
        it "gets all records" do
          tokyo = subject.create! name: "Tokyo"
          sapporo = subject.create! name: "Sapporo"
          expect(subject.all).to match_array [tokyo, sapporo]
        end
      end
    end

    describe "instance" do
      subject { City.new name: "Tokyo" }

      describe "#save!" do
        it "adds a record to the collection" do
          expect {
            subject.save!
          }.to change { City.all.count }.by(1)
        end

        it "sets an id" do
          expect {
            subject.save!
          }.to change(subject, :id).from(nil)
        end

        it "respects given id" do
          subject.id = "tky"
          subject.save!
          expect(subject.id).to eq "tky"
        end
      end

      describe "#reload" do
        it "reloads" do
          edo = City.create! id: "tky", name: "Edo"
          subject.update! id: "tky"
          expect {
            edo.reload
          }.to change(edo, :name).from("Edo").to("Tokyo")
        end
      end
    end
  end

  describe "belonged model" do
    let(:city) { City.create! id: "tky", name: "Tokyo" }

    before do
      city.streets.delete_all
    end

    describe "proxy class" do
      subject { city.streets }

      describe ".scope" do
        it "returns a scope depending to the parent" do
          expect(subject.scope.path).to be_end_with "cities/tky/streets"
        end
      end

      describe ".build" do
        it "builds a record with the parent set" do
          expect(subject.build.city).to eq city
        end
      end

      describe ".create!" do
        it "adds a record to the collection" do
          subject.delete_all

          expect {
            subject.create! name: "Eitai Street"
          }.to change { subject.all.count }.by(1)
        end
      end

      describe ".find" do
        it "finds a record" do
          eitai = subject.create! id: "et", name: "Eitai Street"
          expect(subject.find("et")).to eq eitai
        end
      end

      describe ".all" do
        it "gets all records" do
          eitai = subject.create! name: "Eitai Street"
          meiji = subject.create! name: "Meiji Street"
          expect(subject.all).to match_array [eitai, meiji]
        end
      end
    end

    describe "instance" do
      subject { city.streets.build name: "Eitai Street" }

      describe "#save!" do
        it "adds a record to the collection" do
          expect {
            subject.save!
          }.to change { city.streets.all.count }.by(1)
        end

        it "sets an id" do
          expect {
            subject.save!
          }.to change(subject, :id).from(nil)
        end
      end

      describe "#reload" do
        it "reloads" do
          st = city.streets.create! id: "et", name: "Street"
          subject.update! id: "et"
          expect {
            st.reload
          }.to change(st, :name).from("Street").to("Eitai Street")
        end
      end
    end
  end
end
