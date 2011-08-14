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
end  

l = LOL.new

l.lol                    # [1, 2, 3]
l.lol(3, 2)              # [3, 2, 3]
l.lol(a: true)           # [true, 2, 3]
l.lol(a: true, b: false) # [true, false, 3]
l.lol(a: true, c: false) # [true, nil, false]
````

Please note that the last call has `nil` in b, this is because there's no way
to tell Ruby _this parameter should be filled with the optional value_, so
if you want people to use it that way, make sure to use `nil` and set the default
value on `nil`
