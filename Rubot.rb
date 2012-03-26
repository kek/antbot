$:.unshift File.dirname($0)
require 'ants.rb'

ai=AI.new
orders = {}
AVOID_TIME = 20

ai.setup do |ai|
  # your setup code here, if any
end

ai.run do |ai|
  current_orders = {}

  ai.my_ants.each do |ant|
    directions = [:N, :E, :S, :W]
    directions = directions.sort { |x,y| rand - 0.5 }

    all_blocked = directions.reject { |dir|
      loc = ant.square.neighbor(dir)

      !loc.land? or
      (orders[loc] and (orders[loc] > ai.turn_number - AVOID_TIME + AVOID_TIME/4)) or
      ant.square.neighbor(dir).ant?
    }.empty?

    directions.each do |dir|
      loc = ant.square.neighbor(dir)
      if loc.land? and
          (all_blocked or !(orders[loc] and (orders[loc] > ai.turn_number - AVOID_TIME))) and
          not current_orders[loc] and
          not loc.ant?
        orders[loc] = ai.turn_number
        current_orders[loc] = true
        ant.order dir
        break
      end
    end
  end
end
