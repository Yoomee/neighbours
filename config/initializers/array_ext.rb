class Array

  def at_least(num)
    array = self.dup
    array.pop if array.size.odd? && array.size > num
    count = 0
    new_array = array
    (num - array.size).times do |i|
      new_array << array[count] if array[count]
      count = (count >= (array.size - 1)) ? 0 : count + 1
    end
    new_array
  end

end