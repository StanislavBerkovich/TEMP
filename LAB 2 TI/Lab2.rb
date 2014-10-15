require 'gruff'

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
    @alpha, @beta, @px = alpha, beta, px
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
  attr_reader :seq, :alpha, :beta, :px

  COUNT_FOR_VAR_SERIES = 10000

  def initialize t, px, alpha, beta
    @px, @alpha, @beta, @dist = px, alpha, beta, BinDistribution.new(px, alpha, beta)
    @seq = Sequence.new t, @dist
  end

  def entropy_X_Y
    entropy_XY - entropy_Y
  end

  def entropy_Y_X
    entropy(@dist.py.flatten)
  end

  def entropy_Y_XplY
    entropy_YXplY - entropy_XplY
  end

  def empirical_entropy_X_Y
    entropy(count_pair_freq) - entropy(count_freq_of_one(:y))
  end

  def empirical_entropy_Y_X
    entropy(count_pair_freq) - entropy(count_freq_of_one(:x))
  end

  def empirical_entropy_Y_XplY
    entropy(count_freq_YXplY) - entropy(count_freq_XplY)
  end

  def graph_family
    for_params = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1]
    puts "Graph family"
    [10**3, 10**5].each do |t|
      for_params.each do |alpha|
        es, ems, xs = [], [], []
        for_params.each do |beta|
          @dist, @alpha, @beta, @px = BinDistribution.new(0.5, alpha, beta), alpha, beta, 0.5
          @seq = Sequence.new t, @dist
          if (alpha > 0.5 && beta >= 1-alpha) || (alpha <= 0.5 && beta <= 1-alpha)
            es << entropy_Y_X
            ems << empirical_entropy_Y_X
            xs << (1-alpha - beta).abs.round(1)
          end
        end
        draw_gruff(title: "alpha = #{alpha}", xs: xs, data: [['Entropy', es], ['Empirical Entropy', ems]])
      end
    end
    res
  end

  def graph_info
    entr_X_Y, entr_Y_X, vars_X_Y, vars_Y_X, ts = entropy_X_Y, entropy_Y_X, [], [], [10, 100, 1000, 10000]
    ts.each do |size|
      vars_X_Y << var_series_X_Y(size, entr_X_Y)
      vars_Y_X << var_series_Y_X(size, entr_Y_X)
      puts "Size: #{size}, var_X_Y: #{vars_X_Y.last}, var_Y_X: #{vars_Y_X.last}"
    end
    draw_gruff({title: "Alpha = #{@alpha}, Beta = #{@beta}, Pi1 = #{@px}", xs: ts, data: [['V(H{x1|x2})', vars_X_Y], ['V(Hemp{x2|x1})', vars_Y_X]]})
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
    @seq.arr.each { |pair| pair_freq[2 * pair.x + pair.y] += 1 }
    pair_freq.map { |p| p / @seq.length }
  end

  def count_freq_XplY
    freq = Array.new(3, 0.0)
    @seq.arr.each { |pair| freq[pair.x + pair.y] += 1 }
    freq.map { |p| p / @seq.length }
  end

  def count_freq_YXplY
    freq = Array.new(6, 0.0)
    @seq.arr.each do |pair|
      index = 2 * pair.y + (pair.y == 0 ? pair.x : pair.x + 1)
      freq[index] += 1
    end
    freq.map { |p| p / @seq.length }
  end

  def count_freq_of_one p
    freq_p = Array.new(2, 0.0)
    @seq.arr.each { |pair| freq_p[pair.send(p)] += 1 }
    freq_p.map { |p| p / @seq.length }
  end

  def nu p
    p == 0 ? 0 : Math.log2(p)
  end

  def entropy_YXplY
    entropy [((1 - @px) * @alpha + @px * (1 - @beta)) * (1 - @px), ((1 - @px) * @alpha + @px * (1 - @beta)) * @px, 0,
             0, ((1 - @px) * (1 - @alpha) + @px * @beta) * (1-@px), ((1 - @px) * (1 - @alpha) + @px * @beta) * @px]

  end

  def entropy arr
    arr.inject(0) do |entropy, p|
      entropy - p * nu(p)
    end
  end

  def entropy_XY
    unless @entropyXY
      @entropyXY = entropy([@px, 1-@px]) + entropy_Y_X
    else
      @entropyXY
    end
  end

  def entropy_Y
    unless @entropyY
      @entropyY = entropy([@alpha * (1 - @px) + @px * (1-@beta), @beta * @px + (1-@alpha) * (1-@px)])
    else
      @entropyY
    end
  end

  def entropy_XplY
    unless @entropyXplY
      @entropyXplY = entropy([@px * @alpha, @px *(1- @beta) + (1 - @px) *(1- @alpha), @px * @beta])
    else
      @entropyXplY
    end
  end

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
    arr.sort.each_with_index { |a, i| res[i] = a.to_s[0...3] }
    res
  end

end


data = [[0.3, 0.8, 0.5], [0.7, 0.2, 0.6], [0.3, 0.5, 0.4], [0.4, 0.5, 0, 6]]
data.each do |d|
  l = Lab2.new 20, d[0], d[1], d[2]
  puts "Alpha = #{l.alpha}, Beta = #{l.beta}, Pi1 = #{l.px}"
  puts 'Sequence:'
  l.seq.arr.each do |a|
    print "#{a}, "
  end
  puts
  puts "Entropy X | Y : ", l.entropy_X_Y
  puts "Entropy Y | X : ", l.entropy_Y_X
  puts "Empiric Entropy X | Y : ", l.empirical_entropy_X_Y
  puts "Empiric Entropy Y | X : ", l.empirical_entropy_Y_X
  puts "Entropy Y | X+Y : ", l.entropy_Y_XplY
  puts "Empiric Entropy Y | X+Y", l.empirical_entropy_Y_XplY
  l.graph_info

end
l = Lab2.new 1, 1, 0.2, 0.4
l.graph_family
