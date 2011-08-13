#--
#           DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                   Version 2, December 2004
#
#  Copyleft meh. [http://meh.paranoid.pk | meh@paranoici.org]
#
#           DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#  TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.
#++

require 'refining'
require 'ap'

class Module
  refine_method :method_added do |old, *args|
    if @__to_namedify__
      namedic(instance_method(args.first), *@__to_namedify__)
    elsif @__always_namedic__ or @__to_auto_namedify__
      auto_namedic(instance_method(args.first))
    end
    
    old.call(*args)
  end
end

class Object
  def namedic (*args)
    if args.first.nil?
      @__to_auto_namedify__ = true
    elsif !args.first.is_a?(Method)
      @__to_namedify__ = args
    end and return

    @__to_auto_namedify__ = false
    @__to_namedify__      = false

    options = Hash[
      :optional => [],
      :rest     => false
    ].merge(args.last.is_a?(Hash) ? args.pop : {})

    method = args.shift
    names  = args

    method.owner.refine_method method.name do |old, *args|
      if (args.length != 1 || !args.first.is_a?(Hash)) || (options[:rest] && !args.last.is_a?(Hash))
        return old.call(*args) 
      end

      parameters = args.pop
      rest       = args
      args       = []

      raise ArgumentError, "#{key} is an unknown parameter" unless parameters.keys.all? {|parameter|
        names.member?(parameter)
      }

      (parameters.keys - options[:optional].map { |(name, value)| name }).tap {|required|
        raise ArgumentError, "#{required.join(', ')} are required" unless required.empty?
      }

      names.each {|name|
      }

      old.call(*args)
    end
  end

  def auto_namedic (method)
    method.parameters.map {|how, name|
      
    }
  end

  def always_namedic
    @__always_namedic__ = true
  end
end
