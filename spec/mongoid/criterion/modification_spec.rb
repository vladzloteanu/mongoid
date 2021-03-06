require "spec_helper"

describe Mongoid::Criteria do

  [ :update, :update_all ].each do |method|

    let!(:person) do
      Person.create(:title => "Sir")
    end

    let!(:address_one) do
      person.addresses.create(:street => "Oranienstr")
    end

    let!(:address_two) do
      person.addresses.create(:street => "Wienerstr")
    end

    describe "##{method}" do

      context "when updating the root document" do

        context "when updating with a criteria" do

          let(:from_db) do
            Person.first
          end

          before do
            Person.where(:title => "Sir").send(method, :title => "Madam")
          end

          it "updates all the matching documents" do
            from_db.title.should eq("Madam")
          end
        end

        context "when updating all directly" do

          let(:from_db) do
            Person.first
          end

          before do
            Person.send(method, :title => "Madam")
          end

          it "updates all the matching documents" do
            from_db.title.should eq("Madam")
          end
        end
      end

      context "when updating an embedded document" do

        before do
          Person.where(:title => "Sir").send(
            method,
            "addresses.0.city" => "Berlin"
          )
        end

        let!(:from_db) do
          Person.first
        end

        it "updates all the matching documents" do
          from_db.addresses.first.city.should eq("Berlin")
        end

        it "does not update non matching documents" do
          from_db.addresses.last.city.should be_nil
        end
      end

      context "when updating a relation" do

        context "when the relation is an embeds many" do

          let(:from_db) do
            Person.first
          end

          context "when updating the relation directly" do

            before do
              person.addresses.send(method, :city => "London")
            end

            it "updates the first document" do
              from_db.addresses.first.city.should eq("London")
            end

            it "updates the last document" do
              from_db.addresses.last.city.should eq("London")
            end
          end

          context "when updating the relation through a criteria" do

            before do
              person.addresses.where(:street => "Oranienstr").send(
                method, :city => "Berlin"
              )
            end

            it "updates the matching documents" do
              from_db.addresses.first.city.should eq("Berlin")
            end

            it "does not update non matching documents" do
              from_db.addresses.last.city.should be_nil
            end
          end
        end

        context "when the relation is a references many" do

          let!(:post_one) do
            person.posts.create(:title => "First")
          end

          let!(:post_two) do
            person.posts.create(:title => "Second")
          end

          context "when updating the relation directly" do

            before do
              person.posts.send(method, :title => "London")
            end

            let!(:from_db) do
              Person.first
            end

            it "updates the first document" do
              from_db.posts.first.title.should eq("London")
            end

            it "updates the last document" do
              from_db.posts.last.title.should eq("London")
            end
          end

          context "when updating the relation through a criteria" do

            before do
              person.posts.where(:title => "First").send(
                method, :title => "Berlin"
              )
            end

            let!(:from_db) do
              Person.first
            end

            it "updates the matching documents" do
              from_db.posts.where(:title => "Berlin").count.should eq(1)
            end

            it "does not update non matching documents" do
              from_db.posts.where(:title => "Second").count.should eq(1)
            end
          end
        end

        context "when the relation is a references many to many" do

          let(:from_db) do
            Person.first
          end

          let!(:preference_one) do
            person.preferences.create(:name => "First")
          end

          let!(:preference_two) do
            person.preferences.create(:name => "Second")
          end

          context "when updating the relation directly" do

            before do
              person.preferences.send(method, :name => "London")
            end

            it "updates the first document" do
              from_db.preferences.first.name.should eq("London")
            end

            it "updates the last document" do
              from_db.preferences.last.name.should eq("London")
            end
          end

          context "when updating the relation through a criteria" do

            before do
              person.preferences.where(:name => "First").send(
                method, :name => "Berlin"
              )
            end

            it "updates the matching documents" do
              from_db.preferences.first.name.should eq("Berlin")
            end

            it "does not update non matching documents" do
              from_db.preferences.last.name.should eq("Second")
            end
          end
        end
      end
    end
  end
end
