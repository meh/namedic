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

class Module
  refine_method :method_added do |old, *args|
    @__last_method__ = args.first
  
    if @__to_namedify__
      namedic(instance_method(@__last_method__), *@__to_namedify__)
    end
    
    old.call(*args)
  end
end

class Object
  def namedic (*args)
    if args.first.nil?
      begin
        auto_namedic(instance_method(@__last_method__))
      rescue
        self.class.instance_eval {
          auto_namedic(instance_method(@__last_method__))
        }
      end
    elsif ![Method, UnboundMethod].any? { |klass| args.first.is_a?(klass) }
      @__to_namedify__ = args
    end and return

    @__to_auto_namedify__ = @__to_namedify__ = false

    options = Hash[
      :optional => [],
      :rest     => []
    ].merge(args.last.is_a?(Hash) ? args.pop : {})

    method = args.shift
    names  = args

    method.owner.refine_method method.name do |old, *args|
      unless (args.length != 1 || !args.first.is_a?(Hash)) || (options[:rest] && !args.last.is_a?(Hash))
        parameters = args.pop
        rest       = args
        args       = []

        parameters.keys.each {|parameter|
          raise ArgumentError, "#{parameter} is an unknown parameter" unless names.member?(parameter)
        }

        (names - parameters.keys - options[:optional].map { |param| param.is_a?(Hash) ? param.keys : param }.flatten.compact).tap {|required|
          raise ArgumentError, "the following required parameters are missing: #{required.join(', ')}" unless required.empty?
        }

        names.each_with_index {|name, index|
          if parameters.has_key?(name)
            if options[:rest].member?(name)
              args.push(*parameters[name])
            else
              args << parameters[name]
            end
          else
            args << nil
          end
        }
      end

      old.call(*args)
    end
  end

  def auto_namedic (method)
    names   = []
    options = { :rest => [], :optional => [] }

    method.parameters.map {|how, name|
      if name
        names << name
        
        options[:optional] << name if how == :opt
        options[:rest]     << name if how == :rest
      else
        names          << rand.to_s
        options[:rest] << names.last
      end
    }

    namedic(method, *names, options)
  end

  def always_namedic
    @__always_namedic__ = true
  end
end
