class String
  def >>(value)
    puts self.class
    self.replace(value + self)
  end
end

s = 'world'
s >> 'hello '
puts s
