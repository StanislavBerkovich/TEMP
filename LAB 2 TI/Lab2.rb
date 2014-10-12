require 'pry'

class Pair
  attr_reader :x, :y

  def initialize x, y
    @x, @y = x, y
  end

  def to_s
    "{#{@x}, #{@y}}"
  end
end

class BinDistribution
  attr_reader :alpha, :beta, :px, :py

  def initialize px, alpha, beta
    @alpha, @beta, @px = px, alpha, beta
    @py = [[@alpha, 1 - @alpha],
           [1- @beta, @beta]]
  end

  def generate_pair
    x = to_i(rand <= @px)
    Pair.new(x, to_i(rand >= @py[x][0]))
  end

  private

  def to_i p
    p ? 1 : 0;
  end
end

class Sequence
  attr_reader :arr

  def initialize t, dest
    @T, @dest, @arr= t, dest, []
    generate
  end

  def generate
    @T.times { @arr << @dest.generate_pair }
  end

  def length
    @T
  end

  def to_s
    puts @arr
  end
end

class Lab2
  attr_reader :seq

  COUNT_FOR_VAR_SERIES = 10000

  def initialize t, px, alpha, beta
    @px, @alpha, @beta, @dist =  px, alpha, beta, BinDistribution.new(px, alpha, beta)
    @seq = Sequence.new t, @dist
  end

  def entropy_X_Y
    entropy_XY - entropy_Y
  end

  def entropy_Y_X
    (1-@px)*(nu(@alpha)+nu(1-@alpha)) + @px*(nu(@beta)+nu(1-@beta))
  end

  def entropy_Y_XplY
    entropy_XY - entropy_XplY
  end

  def empirical_entropy_X_Y
    pair_freq, freq_y = count_pair_freq, count_freq_of_one(:y)
    freq_y[1] * (nu(pair_freq[0]) + nu(pair_freq[2])) + freq_y[0] * (nu(pair_freq[1]) + nu(pair_freq[3]))
  end

  def empirical_entropy_Y_X
    pair_freq, freq_x = count_pair_freq, count_freq_of_one(:x)
    freq_x[0] * (nu(pair_freq[0]) + nu(pair_freq[1])) + freq_x[1] * (nu(pair_freq[2]) + nu(pair_freq[3]))
  end

  def empirical_entropy_Y_XplY
    sum_freq, freq_y = count_freq_XplY, count_freq_of_one(:y)
    #TODO: Дописать
  end

  def graph_info
    entr_X_Y, entr_Y_X, vars_X_Y, vars_Y_X, ts = entropy_X_Y, entropy_Y_X, [], [], [10, 100, 1000, 10000]
    ts.each do |size|
      vars_X_Y << var_series_X_Y(size, entr_X_Y)
      vars_Y_X << var_series_Y_X(size, entr_Y_X)
      puts "Size: #{size}, var_X_Y: #{vars_X_Y.last}, var_Y_X: #{vars_Y_X.last}"
    end
  end

  private

  def var_series_X_Y t, entropyX_Y
    res = 0
    COUNT_FOR_VAR_SERIES.times do
      @seq = Sequence.new t, @dist
      entropy = empirical_entropy_X_Y
      res += (entropy - entropyX_Y) ** 2
    end
    res / COUNT_FOR_VAR_SERIES
  end

  def var_series_Y_X t, entropyY_X
    res = 0
    COUNT_FOR_VAR_SERIES.times do
      @seq = Sequence.new t, @dist
      entropy = empirical_entropy_Y_X
      res += (entropy - entropyY_X) ** 2
    end
    res / COUNT_FOR_VAR_SERIES
  end

  def count_pair_freq
    pair_freq = Array.new(4, 0.0)
    @seq.arr.each { |pair|  pair_freq[2 * pair.x + pair.y] += 1 }
    pair_freq.map { |p| p / @seq.length }
  end


  def count_freq_XplY
    freq = Array.new(3,0.0)
    @seq.arr.each { |pair| freq[pair.x + pair.y] += 1 }
    freq.map { |p| p / @seq.length }
  end

  def count_freq_of_one p
    freq_p = Array.new(2,0.0)
    @seq.arr.each { |pair| freq_p[pair.send(p)] += 1 }
    freq_p.map { |p| p / @seq.length }
  end

  def nu p
    p == 0 ? 0 : -p * Math.log2(p)
  end

  def entropy_XY
    nu((1 - @px) * @alpha) + nu( @px * (1 - @beta) ) + nu(( 1 - @px) * (1 - @alpha)) + nu(@px * @beta)
  end

  def entropy_Y
    nu((1 - @px) * @alpha + @px * (1 - @beta)) + nu((1 - @px) * (1 - @alpha) + @px * @beta)
  end

  def entropy_XplY
    nu((1 - @px) * @alpha) + nu(@px * (1 - @beta) + (1 - @px) * (1 - @alpha)) + nu(@px * @beta)
  end
end




alpha, beta, px = 0.3, 0.5, 0.7
l = Lab2.new 20, px, alpha, beta
puts l.seq.arr
puts "Entropy X | Y : ", l.entropy_X_Y
puts "Entropy Y | X : ", l.entropy_Y_X
puts "Empiric Entropy X | Y : ", l.empirical_entropy_X_Y
puts "Empiric Entropy Y | X : ", l.empirical_entropy_Y_X
l.graph_info
