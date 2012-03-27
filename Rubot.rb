$:.unshift File.dirname($0)
require 'ants.rb'

def log s
  # $stderr.puts s
end

ai=AI.new
history = {}
visits = {}

ai.setup do |ai|
  # your setup code here, if any
end

ai.run do |ai|
  current_orders = {}

  ai.my_ants.each_with_index do |ant, i|

    log "Distance between -1,0 and 0,5:"
    log ai.distance([-1,0], [0,5])

    log "Fastest route between 0,0 and 1,1:"
    log ai.direction([0,0], [1,1])

    log "\nAnt #{i}:"

    close_foods = ai.foods.sort { |food|
      ai.distance([ant.row, ant.col], [food[0], food[1]])
    }.reject { |food|
      ai.distance([ant.row, ant.col], [food[0], food[1]]) > ai.viewradius / 2
    }

    close_hills = ai.enemy_hills.sort { |hill|
      ai.distance([ant.row, ant.col], [hill[0], hill[1]])
    }.reject { |hill|
      ai.distance([ant.row, ant.col], [hill[0], hill[1]]) > ai.viewradius
    }

    scores = [:N, :E, :S, :W].map { |dir|
      dest = ant.square.neighbor(dir)
      if !dest.land? or dest.ant?
        score = nil
      elsif history[dest]
        # Higher age is good
        score = ai.turn_number - history[dest]

        # if age < 5 and age > 2
        #   score = score + 1000
        # else
        #   score = age
        # end
      else
        # Untravelled is best choice
        score = 1001
      end


      if score

        if close_hills.length > 0 and
            ai.direction([ant.row, ant.col], close_hills[0]).member? dir
          log "******************* HILL HUNT *************************"
          score += 300
        end

        if close_foods.length > 0 and
            ai.direction([ant.row, ant.col], close_foods[0]).member? dir
          log "******************* FOOD HUNT *************************"
          score += 300
        end

        score = score - (visits[dest] or 0) * ai.my_ants.length.to_f / 10

        log "ant #{i} - #{dir} - score #{score or 'nil'}" unless !score
      end

      { dir => score }
    }

    scores = scores.reduce(Hash.new) { |memo, obj|
      memo.merge obj
    }

    # log "scores for ant #{i}:"
    # scores.each_pair do |key, value|
    #   log "direction #{key} - score #{value}"
    # end

    directions = [:N, :E, :S, :W].sort {|x| 0.5 <=> rand }.reject { |dir|
      scores[dir] == nil
    }.sort { |x,y|
      scores[x] <=> scores[y]
    }.reverse

    # log "Possible moves, in order:"
    # directions.each {|dir|
    #   log "#{dir} - #{scores[dir]}"
    # }

    if directions.length > 0
      dir = directions.first

      dest = ant.square.neighbor(dir)

      log "ant #{i} going #{dir} with #{visits[dest] or 0} visits"

      if !current_orders[dest]
        ant.order dir
        current_orders[dest] = true
        history[dest] = ai.turn_number
        visits[dest] = (visits[dest] or 0) + 1
      else
        log "Blocked"
      end
    else
      log "No good move for ant #{i}"
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
