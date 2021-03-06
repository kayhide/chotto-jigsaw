require "rails_helper"

RSpec.describe FireRecord::Scope do
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

        it "raises DocumentNotFound when not found" do
          expect{
            subject.find("zzz")
          }.to raise_error(FireRecord::DocumentNotFound)
        end
      end

      describe ".all" do
        it "gets all records" do
          tokyo = subject.create! name: "Tokyo"
          sapporo = subject.create! name: "Sapporo"
          expect(subject.all).to match_array [tokyo, sapporo]
        end
      end

      describe ".delete_all" do
        it "deletes all records" do
          subject.create! name: "Tokyo"
          subject.create! name: "Sapporo"
          expect {
            subject.delete_all
          }.to change { subject.count }.from(2).to(0)
        end

        it "deletes all records more than 500" do
          2.times do
            subject.batch do |b|
              260.times do
                subject.create!({ name: "Tokyo" }, b)
              end
            end
          end
          expect {
            subject.delete_all
          }.to change { subject.count }.from(520).to(0)
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

        it "sets reference attribute" do
          eitai = subject.create! id: "et", name: "Eitai Street"
          expect(subject.find("et").city_id).to eq city.id
        end
      end

      describe ".all" do
        it "gets all records" do
          eitai = subject.create! name: "Eitai Street"
          meiji = subject.create! name: "Meiji Street"
          expect(subject.all).to match_array [eitai, meiji]
        end

        it "sets reference attribute" do
          eitai = subject.create! name: "Eitai Street"
          meiji = subject.create! name: "Meiji Street"
          expect(subject.all.map(&:city_id)).to all eq city.id
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

  describe "inherited model" do
    class Owner
      include FireRecord::Document
      include FireRecord::Collection
      has_many_docs :animals
    end

    class Animal
      include FireRecord::Document
      belongs_to :owner
      attribute :type, :string
      attribute :name, :string
    end

    class Cat < Animal
      attribute :mew, :string
    end

    class Dog < Animal
      attribute :bow, :string
    end

    before do
      Animal.delete_all
    end

    describe "base class" do
      subject { Animal }

      describe ".scope" do
        it "returns a scope" do
          expect(subject.scope.path).to be_end_with "animals"
        end
      end
    end

    describe "inherited class" do
      describe ".scope" do
        it "returns a scope of document defined" do
          expect(Cat.scope.path).to be_end_with "animals"
          expect(Dog.scope.path).to be_end_with "animals"
        end
      end

      describe ".find" do
        it "downcasts" do
          mike = Cat.create! id: "mike", name: "Mike", mew: "Meeew"
          taro = Dog.create! id: "taro", name: "Taro", bow: "Bowow"
          expect(Animal.find("mike")).to eq mike
          expect(Animal.find("taro")).to eq taro
        end
      end

      describe ".all" do
        it "downcasts" do
          mike = Cat.create! id: "mike", name: "Mike", mew: "Meeew"
          taro = Dog.create! id: "taro", name: "Taro", bow: "Bowow"
          expect(Animal.all).to eq [mike, taro]
        end
      end
    end

    describe "instance" do
      describe "#save!" do
        it "sets type attribute" do
          expect(Cat.new.save!.type).to eq "Cat"
          expect(Dog.new.save!.type).to eq "Dog"
        end
      end
    end

    describe "belonged inherited class" do
      let(:owner) { Owner.create! }
      subject { owner.animals }

      before do
        subject.delete_all
      end

      describe ".find" do
        it "downcasts and sets reference attribute" do
          mike = subject.build.becomes(Cat).update! id: "mike", name: "Mike", mew: "Meeew"
          taro = subject.build.becomes(Dog).update! id: "taro", name: "Taro", bow: "Bowow"
          expect(subject.find("mike").owner_id).to eq owner.id
          expect(subject.find("taro").owner_id).to eq owner.id
        end
      end

      describe ".all" do
        it "downcasts and sets reference attribute" do
          mike = subject.build.becomes(Cat).update! id: "mike", name: "Mike", mew: "Meeew"
          taro = subject.build.becomes(Dog).update! id: "taro", name: "Taro", bow: "Bowow"
          expect(subject.all.map(&:owner_id)).to all eq owner.id
        end
      end
    end
  end
end
