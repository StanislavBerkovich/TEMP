# encoding: UTF-8

module Lab1
	attr_reader :ps, :real_ps
	attr_accessor :t

	def teor_entropy
		entropy @ps
	end

	def data_for_hist_and_graph
		puts "votes = #{@result}"
		puts generate_bins
		series = variational_series
		puts "x = #{series.keys}"
		puts "y = #{series.values}"
	end

	def variational_series 
		number_for_e = 1000
		x_for_variation_series = [10, 20, 50, 100, 1000, 10000, 100000]
		series = {}
		t_en = self.teor_entropy
		x_for_variation_series.each do |i|
			self.t = i
			real_entropes = []
			number_for_e.times do 
				self.generate
				real_entropes << (self.real_entropy - t_en) ** 2
			end
			series[i] = real_entropes.inject(0){|e, re| e + re.to_f} / number_for_e
		end
		series
	end 

	def real_entropy
		entropy real_ps
	end

	def entropy arr_ps
		arr_ps.inject(0) do |entropy, p|
				entropy - (p == 0 ? 0 :  p * Math.log(p) / Math.log(2) ) 
	 	end
	end

end


class Binomial
	include Lab1

	def initialize(args = {})
		@t = args[:T] || 10
		@n = args[:N] || 2
		@p = args[:P] || 0.5
		generate
	end

	def real_ps
		real_p = @result.inject(0){|sum, x| sum + x}.to_f
		real_p /= (@t * @n)
		real_ps = (0..@n).map{|x| ( c(@n, x) * (1.0 - real_p) ** (@n - x)) * (real_p ** x)}
		real_ps
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

	def generate_bins
		bins = "b = [-0.5"
		(0..(@n-1)).each do |i|
			bins << ", #{i}.5"
		end
		bins << ", #{@n}.5]"
		bins
	end

	private 

	def c n, k
		fact(n) / ( fact(k) * fact(n-k) )
	end

	def fact n
		(1..n).inject(1){|fact, k| fact * k} 
	end

end

class Descrete
	include Lab1

	attr_reader :result

	def initialize(args = {})
		@t = args[:T] || 10
		@n = args[:N] || 5
		generate_fs
	end

	def real_ps
		@real_ps = Array.new(@n) { 0 }
		@result.each { |i| @real_ps[i] += 1.0 }
		@real_ps.map!{ |i| i / @t}
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

	def generate_bins
		bins = "b = [-0.5"
		(0..(@n-2)).each do |i|
			bins << ", #{i}.5"
		end
		bins << ", #{@n-1}.5]"
		bins
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

	
end

def show_info b
	puts 'Теорическая вероятность'; print b.ps; puts
	puts "Теорическая энтропия"; puts b.teor_entropy
	puts 'Эмпирическая вероятность';	print b.real_ps; puts
	puts "Эмпирическая энтропия"; puts b.real_entropy; puts
	5.times{puts "************************************"}
	puts "Данные для построения гистограмы и графиков"; puts b.data_for_hist_and_graph
	5.times{puts "************************************"}
end



params = [{P:0.1, N:2, T: 300}, {P: 0.25, N: 5, T: 1000}, {P: 0.5, N:4, T: 2500}, {P:0.6, N: 6, T: 2000}, {P:0.4, N: 3, T: 1500}]
puts "Биномиальное распределение:"
params.each do |h|
	puts
	puts "N = #{h[:N]}, T = #{h[:T]}, P=#{h[:P]}"
 	show_info Binomial.new h
 end

puts "Дискретное распределение:"
params.each do |h|
	puts
	puts "N = #{h[:N]}, T = #{h[:T]}, P=#{h[:P]}"
 	show_info Descrete.new h
 end
# puts
#  Binomial.new( N: 10, P: 0.25).real_ps
# ap Descrete.new( N: 10, P: 0.25).variational_series
