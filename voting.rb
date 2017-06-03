# coding: utf-8

class Voting
  def initialize(targets)
    @targets = targets
    @intermediate = {}
  end

  attr_reader :intermediate

  def vote(member, target)
    @targets.include?(target) or raise ArgumentError
    @intermediate[member] = target
  end

  def finish
    result = @targets.map {|t| [t, 0] }.to_h
    @intermediate.each do |k, v|
      result[v] += 1
    end
    result
  end
end
