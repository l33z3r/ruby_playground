class Vec3
  attr_accessor :x, :y, :z

  def initialize(x, y, z)
    @x = x
    @y = y
    @z = z
  end

  # Vector multiply
  def *(a)
    if a.is_a?(Numeric) # Scalar Multiply
      return Vec3.new(a * @x, a * @y, a * @z)
    else # Dot Product
      return a.x * @x + a.y * @y + a.z * @z
    end
  end

  def coerce(other)
    return self, other
  end
end

a = Vec3.new(2, 2, 2)
b = a * 3
c = 4 * a

puts c.x