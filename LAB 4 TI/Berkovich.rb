# encoding: UTF-8

module OptFeatures
	def self.mean seq
		seq.inject(0.0){|sum, el| sum + el} / seq.length.to_f
	end

	def self.dev seq
		mean = self.mean(seq)
		seq.inject(0.0){|sum, el| sum + (el - mean) ** 2 } / seq.length.to_f
	end
end

module Integral
	def self.count a, b, &fun
		value1 = (b-a) * fun.call(middle(a,b))
		value0 = value1 + 1.0
		n = 1.0
		eps = 10e-9
		loop do		
			return middle(value1, value0) if (value1 - value0).abs < eps
			n *= 2.0
			h = (b-a)/n
			value0 = value1
			value1 = 0.0
			for i in 0...n do
				value1 += ((b-a) / n) * fun.call(middle(a + i * h ,a + (i + 1) * h))
			end
		end
	end

	def self.middle a, b
		0.5 * (a + b)
	end
end

class GaussDist
	def initialize mean, dev
		@@ready = false 
		@mean = mean
		@@second = 0
		@dev = dev
	end

	def generate_next
		if @@ready
			@@ready = false
			@@second * @dev + @mean
		else
			u, v, s = 0, 0, 0
			loop do
				u, v  = 2.0 * rand() - 1.0, 2.0 * rand() - 1.0
				s = u ** 2 + v ** 2
				break unless s > 1.0|| s == 0.0
			end
			r = Math.sqrt -2.0 * Math.log(s) / s
			@@second = r * u
			@@ready = true
			r * v * @dev + @mean
		end
	end

	def generate_sequence length 
		seq = []
		length.times{seq << generate_next}
		seq
	end

	def informtion_entropy
		entropy @dev
	end

	def real_entropy seq
		entropy OptFeatures.dev seq
	end

	def entropy dev
		Math.log(Math.sqrt dev * 2.0 * Math.PI * Math.E)
	end

	def standard_deviation length
		n =  100
		deviation = 0.0
		ent = informtion_entropy
		n.times do
			seq = generate_sequence length
			deviation += (ent - real_entropy(seq))**2
		end
		deviation / n.to_f
	end

	def standard_deviation_series
		lengths = [100, 1000, 10e4, 10e5, 10e6, 10e7]
		lengths.each do |length|
			puts "#{length} => #{standard_deviation}"
		end
	end

	
end

def cout seq
	f = File.open('t.txt', 'w')
	f.write 'x = c('
	f.write seq.join(', ')
	f.write ')'
	f.close
end

g = GaussDist.new(0.0, 2.0)
cout g.generate_sequence 10e6.to_i