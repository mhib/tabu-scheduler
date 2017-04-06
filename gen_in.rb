(1..12).each do |y|
  (1..8).each do |x|
    min = rand(5.5..9.9)
    mid = min + rand(0.5..3.6)
    max = mid + rand(1.1..8.6)
    puts("#{y}, #{x}, #{min}, #{mid}, #{max}")
  end
end
