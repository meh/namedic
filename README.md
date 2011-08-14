Namedic -- named parameters in Ruby, again
==========================================

Stupid and ugly named parameters.

Some examples:

```ruby
require 'namedic'

class LOL
  namedic :a, :b, :c, :optional => 0 .. -1
  def lol (a=1, b=2, c=3)
    [a, b, c]
  end  

  namedic :a, :b, :c, :optional => [:a => 1, :b => 2, :c => 3]
  def omg (a=1, b=2, c=3)
    [a, b, c]
  end

  namedic def wat (a, b)
    [a, b]
  end
end  

l = LOL.new


l.lol                       # [1, 2, 3]
l.lol(3, 2)                 # [3, 2, 3]
l.lol(:a => true)           # [true, 2, 3]
l.lol(:a => true, :b => false) # [true, false, 3]
l.lol(:a => true, :c => false) # [true, nil, false]
l.omg(:a => true, :c => false) # [true, 2, false]
l.wat(1, 2)                 # [1, 2]
l.wat(:b => 2, :a => 1)     # [1, 2] on 1.9, exception on 1.8
l.wat(2 => 2, 1 => 1)       # [1, 2] on 1.8 too
````

Please note that the last call has `nil` in b, this is because there's no way
to tell Ruby _this parameter should be filled with the optional value_, so
if you want people to use it that way, make sure to use `nil` and set the default
value on `nil` OR make the optionals explicit and give them a value
