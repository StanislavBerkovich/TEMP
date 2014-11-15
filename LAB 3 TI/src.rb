require 'gruff'
class MarkovGen
	def initialize extent, hash
		@extent = extent
		@p_s = hash[:pi]
    print hash[:pi]
    puts
		@p = extent == 1 ? hash[:mat] : hash[:cube]
	end

	def generate_sequence(hash)
		seq = generate_start
		(hash[:t]-@extent).times { seq << generate_next(seq)}
		seq
	end

	def teor_udel_entropy
		# entropy(@p_s) + ( - @extent) * entropy(@p.flatten @extent)
		entropy(@p.flatten @extent)
	end

	def emperical_udel_entropy seq
		entropy(count_freq(seq).flatten @extent)
  end

  def graphic
    puts "prepare gruff..."
    es, ems, ts = [], [], [10, 100, 1000, 10**4, 10**5, 10**7]
    ts.each do |t|
      sum = 0
      10.times do
        seq = generate_sequence t: t
        sum += emperical_udel_entropy(seq)
        # puts sum
      end
      # puts sum / 10.0
      # puts
      ems << (sum / 10.0)
     end
    tue = teor_udel_entropy
    ts.length.times { es << tue		}
    puts 'Draw gruff...'
    # print ems
    # puts
    draw_gruff(title: "Alphabet power: #{alpha_count} Extent: #{@extent}", xs: ts, data: [['Real', es], ['Empirical', ems]])
  end

	private

  def draw_gruff hash
    g = Gruff::Line.new
    g.title = hash[:title]
    g.labels = to_get_keys(hash[:xs])
    hash[:data].each do |data|
      g.data data[0], data[1]
    end
    g.write("#{hash[:title]}.png")
  end
  def to_get_keys arr
    res = {}
    arr.sort.each_with_index { |a, i| res[i] = a.to_s }
    res
  end

	def generate_start
		v, f= rand, 0
		@p_s.each_with_index do |p, i|
			f += p
			return to_start(i) if v <= f
		end
	end

	def alpha_count
		@extent == 1 ? @p_s.length : Math.sqrt(@p_s.length).to_i
	end

	def count_freq(seq)
		freq = prepare_freq
		(@extent...seq.length).each do |i|
			if @extent == 1
				freq[seq[i-1]][seq[i]] += 1
			else
				 freq[seq[i-2]][seq[i-1]][seq[i]] += 1
			end
		end
		norm(freq)
	end

	def to_start v
		@extent == 1? [v] : [v / alpha_count, v % alpha_count]
	end

	def generate_next arr
		v, f = rand, 0
		curr_p = @extent == 1 ? @p[arr.last] : @p[arr[-2]][arr.last]
    if curr_p == nil
      puts @extent
      print @p
      puts
      print @p_s
      puts
      puts alpha_count
      print arr
      puts
    end
		curr_p.each_with_index do |p, i|
			f += p
			return i if v <= f
		end
	end

	def entropy ps
    sum = 0
    ps.each do |p|
      sum -= p*Math.log2(p) if p > 10e-10
    end
    sum
	end

	def prepare_freq
		freq = []
		alpha_count.times do
			arr = []
			if @extent == 1
				alpha_count.times {arr << 0}
			else
				alpha_count.times do 
					arr1 = []
					alpha_count.times {arr1 << 0}
					arr << arr1
				end 
			end
			freq << arr
		end
		freq
	end

	def norm freq
		freq.each do |arr1|
			if @extent == 1
				sum = arr1.inject(0) {|sum, e| sum + e}.to_f
				arr1.map! {|e| e / sum}
			else
				arr1.each do |arr2|
					sum = arr2.inject(0) {|sum, e| sum + e}.to_f
					arr2.map! {|e| e / sum}
				end
			end
		end
	end
end

#алфавит 3, степень 1
# m = MarkovGen.new 1, {pi: [0.5, 0.3, 0.2 ], mat: [[0.3, 0.2, 0.5], [0.5, 0.1, 0.4], [0.8, 0.1, 0.1]]}
#алфавит 2, степень 1
m = MarkovGen.new 1, {pi: [0.4, 0.6], mat: [[0.3, 0.7], [0.8, 0.2]]}
#алфавит 3, степень 2
# m = MarkovGen.new 2, {pi: [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.2], cube: [[[0.3, 0.2, 0.5], [0.5, 0.1, 0.4], [0.8, 0.1, 0.1]],
# 																																								[[0.2, 0.7, 0.1], [0.4, 0.1, 0.5], [0.6, 0.2, 0.2]],
# 																																								[[0.7, 0.1, 0.2], [0.2, 0.6, 0.2], [0.5, 0.3, 0.2]]] }
#алфавит 2, степень 2 																																								
# m = MarkovGen.new 2, {pi: [0.2, 0.3, 0.4, 0.1], cube: [[[0.3, 0.7], [0.5, 0.5]], [[0.2, 0.8], [0.6, 0.4]]]}
# puts m.teor_udel_entropy
# puts m.emperical_udel_entropy m.generate_sequence t: 1000000
# m.graphic

# [MarkovGen.new(2, {pi: [0.2, 0.3, 0.4, 0.1], cube: [[[0.3, 0.7], [0.5, 0.5]], [[0.2, 0.8], [0.6, 0.4]]]}),
# [MarkovGen.new(2, {pi: [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1 ], cube: [[[0.3, 0.2, 0.5], [0.5, 0.1, 0.4], [0.8, 0.1, 0.1]],
#                                                                               [[0.2, 0.7, 0.1], [0.4, 0.1, 0.5], [0.6, 0.2, 0.2]],
#                                                                               [[0.7, 0.1, 0.2], [0.2, 0.6, 0.2], [0.5, 0.3, 0.2]]] }),
# MarkovGen.new(1, {pi: [0.5, 0.3, 0.2 ], mat: [[0.3, 0.2, 0.5], [0.5, 0.1, 0.4], [0.8, 0.1, 0.1]]}),
# MarkovGen.new(1, {pi: [0.4, 0.6], mat: [[0.3, 0.7], [0.8, 0.2]]})].each do |m|
  puts m.teor_udel_entropy
  puts m.emperical_udel_entropy m.generate_sequence t: 10**7
  m.graphic
  puts
