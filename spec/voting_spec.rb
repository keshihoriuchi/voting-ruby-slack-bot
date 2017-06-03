# coding: utf-8

require_relative "../voting"

describe Voting do
  let(:voting) { Voting.new(%w(a b c)) }

  describe "#vote" do
    subject { voting.vote("moge", target); voting.intermediate }

    context "Given first of targets" do
      let (:target) { "a" }
      it { is_expected.to eq("moge" => "a") }
    end

    context "Given last of targets" do
      let (:target) { "c" }
      it { is_expected.to eq("moge" => "c") }
    end

    context "When override vote" do
      before { voting.vote("moge", "b") }
      let (:target) { "c" }
      it { is_expected.to eq("moge" => "c") }
    end

    context "Given illegal target" do
      let (:target) { "d" }
      it { expect { subject }.to raise_error(ArgumentError) }
    end
  end

  describe "#finish" do
    subject { voting.finish }
    context "Given no vote" do
      it { is_expected.to eq("a" => 0, "b" => 0, "c" => 0) }
    end

    context "Given 1 vote" do
      before { voting.vote("moge", "a") }
      it { is_expected.to eq("a" => 1, "b" => 0, "c" => 0) }
    end

    context "Given 2 vote to a and 1 vote to b" do
      before do
        voting.vote("moge", "a")
        voting.vote("foo", "a")
        voting.vote("bar", "b")
      end
      it { is_expected.to eq("a" => 2, "b" => 1, "c" => 0) }
    end
  end
end
