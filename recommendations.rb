class EuclidianDistanceCalculator
	def calculate(prefs, person1, person2)
		sum = 0

		prefs[person1].each do |key, value|
			sum += (value - prefs[person2][key]) ** 2 if prefs[person2].has_key?(key)
		end

		return 1 / (1 + sum)
	end	
end

class PearsonCorrelationCalculator
	def calculate(prefs, person1, person2)
		sims = prefs[person1].select { |(k,v)| k if prefs[person2].has_key?(k) }.keys
		similaritiesCount = sims.size

		return if similaritiesCount == 0
				
		sum1 = sims.map {|k| prefs[person1][k]}.reduce(:+)
		sum2 = sims.map {|k| prefs[person2][k]}.reduce(:+)
		
		sumSq1 = sims.map{|k| prefs[person1][k] ** 2}.reduce(:+)
		sumSq2 = sims.map{|k| prefs[person2][k] ** 2}.reduce(:+)
		
		pSum = sims.map{|k| prefs[person1][k] * prefs[person2][k]}.reduce(:+)
		
		num = pSum-(sum1*sum2/similaritiesCount)
		den = Math.sqrt( (sumSq1 - (sum1**2)/similaritiesCount) * (sumSq2 - (sum2**2)/similaritiesCount))
		
		return 0 if den == 0
		
		num/den
	end
end

class Recommender
	def topMatches(people, person)	
		scores = []
		calculator = PearsonCorrelationCalculator.new
		people.each_key do |other|
			scores << [calculator.calculate(people, person, other), other] unless person == other
		end

		# Sort the list so the highest scores appear at the top scores.sort( )
		scores.sort.reverse[0..5]
	end

	def recommend(prefs, person, simCalculator)
		totals = Hash.new(0)
		simSums = Hash.new(0)

		prefs.each do |other, ratings|
			next if other == person
			sim = simCalculator.calculate(prefs, person, other)

			next if sim <= 0

			ratings.each do |movie, rating|
				next if prefs[person].has_key?(movie)

				totals[movie] += rating * sim
				simSums[movie] += sim
			end		
		end

		rankins = totals.map{ |movie, total| [movie, total/simSums[movie]]}

		sortedRanks = rankins.sort_by{ |v| v[1] }
		sortedRanks.reverse	
	end
end

def critics 
	{
		'Lisa Rose'=> {'Lady in the Water'=> 2.5, 'Snakes on a Plane'=> 3.5,
      'Just My Luck'=> 3.0, 'Superman Returns'=> 3.5, 'You, Me and Dupree'=> 2.5,
      'The Night Listener'=> 3.0},
     'Gene Seymour'=> {'Lady in the Water'=> 3.0, 'Snakes on a Plane'=> 3.5,
      'Just My Luck'=> 1.5, 'Superman Returns'=> 5.0, 'The Night Listener'=> 3.0,
      'You, Me and Dupree'=> 3.5},
     'Michael Phillips'=> {'Lady in the Water'=> 2.5, 'Snakes on a Plane'=> 3.0,
      'Superman Returns'=> 3.5, 'The Night Listener'=> 4.0},
     'Claudia Puig'=> {'Snakes on a Plane'=> 3.5, 'Just My Luck'=> 3.0,
      'The Night Listener'=> 4.5, 'Superman Returns'=> 4.0,
      'You, Me and Dupree'=> 2.5},
     'Mick LaSalle'=> {'Lady in the Water'=> 3.0, 'Snakes on a Plane'=> 4.0,
      'Just My Luck'=> 2.0, 'Superman Returns'=> 3.0, 'The Night Listener'=> 3.0,
      'You, Me and Dupree'=> 2.0},
     'Jack Matthews'=> {'Lady in the Water'=> 3.0, 'Snakes on a Plane'=> 4.0,
      'The Night Listener'=> 3.0, 'Superman Returns'=> 5.0, 'You, Me and Dupree'=> 3.5},
     'Toby'=> {'Snakes on a Plane'=>4.5,'You, Me and Dupree'=>1.0,'Superman Returns'=>4.0}}
end


recommender = Recommender.new
puts recommender.recommend(critics, 'Toby', PearsonCorrelationCalculator.new)













