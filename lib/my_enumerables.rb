module Enumerable
  def my_each
    return to_enum(:my_each) unless block_given?

    for kf in self do
      yield kf
    end
    self
  end

  def my_each_with_index(*args)
    return to_enum(:my_each_with_index, *args) unless block_given?

    i = 0
    for kf in self do
      yield kf, i
      i += 1
    end
    self
  end

  def my_select
    return to_enum(:my_select) unless block_given?

    results = []
    my_each { |element| results.push(element) if yield element }
    results
  end

  def my_all?(pattern = nil)
    expr = block_given? ? ->(element) { yield element } : ->(element) { pattern === element }
    my_each { |element| return false unless expr.call(element) }
    true
  end

  def my_any?(pattern = nil)
    expr = block_given? ? ->(element) { yield element } : ->(element) { pattern === element }
    my_each { |element| return true if expr.call(element) }
    false
  end

  def my_none?(pattern = nil)
    expr = ->(element) { yield element } if block_given?
    expr = pattern ? ->(element) { pattern === element } : ->(element) { false ^ element } unless block_given?
    my_each { |element| return false if expr.call(element) }
    true
  end

  def my_count(item = nil)
    return length if item.nil? && !block_given?

    count = 0
    expr = block_given? ? ->(element) { count += 1 if yield element } : ->(element) { count += 1 if item === element }
    my_each { |element| expr.call(element) }
    count
  end

  def my_map(block = nil)
    return to_enum(:my_map) if !block_given? && block.nil?

    result = []
    exp = block_given? ? ->(element) { yield(element) } : ->(element) { block.call(element) }
    my_each { |element| result << exp.call(element) }
    result
  end

  def my_inject(*args)
    case args
    in [a] if a.is_a? Symbol
      sym = a
    in [a] if a.is_a? Object
      initial = a
    in [a, b]
      initial = a
      sym = b
    else
      initial = nil
      sym = nil
    end

    memo = initial || first

    if block_given?
      my_each_with_index do |ele, i|
        next if initial.nil? && i.zero?

        memo = yield(memo, ele)
      end
    elsif sym
      my_each_with_index do |ele, i|
        next if initial.nil? && i.zero?

        memo = memo.send(sym, ele)
      end
    end

    memo
  end
end