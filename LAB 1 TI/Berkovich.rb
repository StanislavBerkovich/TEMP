# encoding: UTF-8
#require "awesome_print"

module Entropy
	attr_reader :ps, :real_ps

	def teor_entropy
		entropy @ps
	end

	def data_for_hist
		puts "votes = #{@result}"
		puts generate_bins
	end

	def generate_bins
		bins = "b = [-0.5, 0.5"
		(1..(@n-2)).each do |i|
			bins << ", #{i}.5"
		end
		bins << ", #{@n-1}.5]"
		bins
	end

	def real_entropy
		entropy real_ps
	end

	def variational_series
		series = {}
		(100..900).step(200).each do |i|
			self.t=i
			series[i] = (teor_entropy - real_entropy).abs
		end
		series
	end 

	def entropy arr_ps
		arr_ps.inject(0) do |entropy, p|
				entropy - (p == 0 ? 0 :  p * Math.log(p) / Math.log(2) ) 
	 	end
	end

end


class Bin
	include Entropy

	def initialize(args = {})
		@t = args[:T] || 10
		@n = args[:N] || 2
		@p = args[:P] || 0.5
		generate
	end

	def t= _t
		@t = _t
		generate
	end

	def real_ps
		real_ps = Array.new(@n + 1) { 0 }
		@result.each { |i| real_ps[i] += 1.0 }
		real_ps.map{ |i| i / @t}
	end

	private 

	def c n, k
		fact(n) / ( fact(k) * fact(n-k) )
	end

	def fact n
		(1..n).inject(1){|fact, k| fact * k} 
	end

	def generate
		@result = []
		@t.times do 
			count = 0
			@n.times do
				count += 1 if rand() <= @p
			end
			@result << count
		end
		@ps = (0..@n).map{|x| ( c(@n, x) * (1.0 - @p) ** (@n - x)) * (@p ** x)}
	end

end

class Diskretnoe
	include Entropy

	attr_reader :result

	def initialize(args = {})
		@t = args[:T] || 10
		@n = args[:N] || 5
		generate_fs
	end

	def t= _t
		@t = _t
		generate
	end


	def real_ps
		@real_ps = Array.new(@n) { 0 }
		@result.each { |i| @real_ps[i] += 1.0 }
		@real_ps.map!{ |i| i / @t}
	end

	private

	def generate_fs
		@fs = []
		@n.times { @fs << rand()}
		sum = @fs.inject(0){ |result, elem| result + elem } 
		@ps = @fs.map {|f| f / sum}
		com_sum = 0
		@fs.map! { |p| com_sum += p / sum }
		generate
	end

	def generate
		@result = []
		@t.times do 
			val = rand()
			@fs.each_with_index do |f, i|
				if f > val
					@result << i
					break
				end
			end
		end
	end
end

def show_info b
	puts "Распределение:"; print b; puts
	puts 'Теорическая вероятность'; print b.ps; puts
	puts "Теорическая энтропия"; puts b.teor_entropy
	puts 'Эмпирическая вероятность';	print b.real_ps; puts
	puts "Эмпирическая энтропия"; puts b.real_entropy
end


# params = [{P:0.1, N:2, T: 10}, {P: 0.25, N: 5, T: 15}, {P: 0.5, N:4, T: 7}, {P:0.6, N: 1, T: 10}, {P:0.4, N: 3, T: 8}]
# puts "Биномиальное распределение:"
# params.each do |h|
# 	puts
# 	puts "N = #{h[:N]}, T = #{h[:T]}, P=#{h[:P]}"
#  	show_info Bin.new h
#  end

# puts "Дискретное распределение:"
# params.each do |h|
# 	puts
# 	puts "N = #{h[:N]}, T = #{h[:T]}, P=#{h[:P]}"
#  	show_info Diskretnoe.new h
#  end
#  puts

# ap Bin.new( N: 10, P: 0.25).variational_series
# ap Diskretnoe.new( N: 10, P: 0.25).variational_series
b = Diskretnoe.new(N:5, P:0.25, T:100)
puts b.data_for_hist