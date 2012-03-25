$:.unshift File.dirname($0)
require 'ants.rb'

ai=AI.new
orders = {}

ai.setup do |ai|
  # your setup code here, if any
end

ai.run do |ai|
  current_orders = {}

  ai.my_ants.each do |ant|
    directions = [:N, :E, :S, :W]
    directions = directions.sort { |x,y| rand - 0.5 }

    directions.each do |dir|
      loc = ant.square.neighbor(dir)
      if loc.land? and
          not ((orders[loc] or 0) > (ai.turn_number - 10)) and
          not current_orders[loc]
        orders[loc] = ai.turn_number
        current_orders[loc] = true
        ant.order dir
        break
      end
    end
  end
end
