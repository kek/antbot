$:.unshift File.dirname($0)
require 'ants.rb'

ai=AI.new
history = {}
visits = {}

ai.setup do |ai|
  # your setup code here, if any
end

ai.run do |ai|
  current_orders = {}

  ai.my_ants.each_with_index do |ant, i|
    $stderr.puts "\nAnt #{i}:"

    scores = [:N, :E, :S, :W].map { |dir|
      dest = ant.square.neighbor(dir)
      if !dest.land? or dest.ant?
        score = nil
      elsif history[dest]
        # Higher age is good
        age = ai.turn_number - history[dest]
        score = age - (visits[dest] or 0) * ai.my_ants.length.to_f / 20

        # if age < 5 and age > 2
        #   score = score + 1000
        # else
        #   score = age
        # end
      else
        # Untravelled is best choice
        score = 1001
      end
      $stderr.puts "ant #{i} - #{dir} - score #{score or 'nil'}" unless !score
      { dir => score }
    }

    scores = scores.reduce(Hash.new) { |memo, obj|
      memo.merge obj
    }

    # $stderr.puts "scores for ant #{i}:"
    # scores.each_pair do |key, value|
    #   $stderr.puts "direction #{key} - score #{value}"
    # end

    directions = [:N, :E, :S, :W].sort {|x| 0.5 <=> rand }.reject { |dir|
      scores[dir] == nil
    }.sort { |x,y|
      scores[x] <=> scores[y]
    }.reverse

    # $stderr.puts "Possible moves, in order:"
    # directions.each {|dir|
    #   $stderr.puts "#{dir} - #{scores[dir]}"
    # }

    if directions.length > 0
      dir = directions.first

      dest = ant.square.neighbor(dir)

      $stderr.puts "ant #{i} going #{dir} with #{visits[dest] or 0} visits"

      if !current_orders[dest]
        ant.order dir
        current_orders[dest] = true
        history[dest] = ai.turn_number
        visits[dest] = (visits[dest] or 0) + 1
      else
        $stderr.puts "Blocked"
      end
    else
      $stderr.puts "No good move for ant #{i}"
    end


    # all_blocked = directions.reject { |dir|
    #   loc = ant.square.neighbor(dir)

    #   !loc.land? or
    #   (history[loc] and (history[loc] > ai.turn_number - AVOID_TIME + AVOID_TIME/4)) or
    #   ant.square.neighbor(dir).ant?
    # }.empty?

    # directions.each do |dir|
    #   loc = ant.square.neighbor(dir)
    #   if loc.land? and
    #       (all_blocked or !(history[loc] and (history[loc] > ai.turn_number - AVOID_TIME))) and
    #       not current_orders[loc] and
    #       not loc.ant?
    #     history[loc] = ai.turn_number unless all_blocked
    #     current_orders[loc] = true
    #     ant.order dir
    #     break
    #   end
    # end
  end
end
