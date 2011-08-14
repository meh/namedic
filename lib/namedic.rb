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

class Namedic
  def initialize (name)
    @name = name.to_sym
  end

  def to_sym
    @name
  end

  def self.arguments (names, options, *args)
    return args if (args.length != 1 || !args.first.is_a?(Hash)) || (options[:rest] && !args.last.is_a?(Hash))

    parameters = args.pop
    rest       = args
    args       = []

    # fix alias parameters
    parameters.dup.each {|name, value|
      if options[:alias].has_key?(name)
        parameters[options[:alias][name]] = value
        parameters.delete(name)
      end
    }

    # check if there are unknown parameters
    parameters.keys.each {|parameter|
      raise ArgumentError, "#{parameter} is an unknown parameter" unless names.member?(parameter)
    }

    # check for missing required parameters
    (names - parameters.keys - options[:optional].map { |param| param.is_a?(Hash) ? param.keys : param }.flatten.compact).tap {|required|
      raise ArgumentError, "the following required parameters are missing: #{required.join(', ')}" unless required.empty?
    }

    # fill the arguments array
    # TODO: try to not add nil for the last optional parameters
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

    args
  end

  def self.definition (method)
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

    [names, options]
  end
end

module Kernel
  def always_namedic
    @always_namedic = true
  end

  def always_namedic?
    @always_namedic
  end
end

class Module
  refine_method :method_added do |old, name|
    @__namedic_last_method__ = name
  
    if @__to_namedify__
      namedic(Namedic.new(@__namedic_last_method__), *@__to_namedify__)
    elsif always_namedic?
      namedic(nil)
    end
    
    old.call(name)
  end

  refine_method :singleton_method_added do |old, name|
    @@__namedic_last_method__ = name
  
    if defined?(@@__to_namedify__) && @@__to_namedify__
      singleton_namedic(Namedic.new(@@__namedic_last_method__), *@@__to_namedify__)
    elsif always_namedic?
      singleton_namedic(nil)
    end
    
    old.call(name)
  end
end

class Object
  def namedic (*args)
    raise ArgumentError, 'you have to pass at least one argument' if args.length == 0

    if args.first.nil?
      return unless @__namedic_last_method__

      names, options = Namedic.definition(instance_method(@__namedic_last_method__))

      return namedic(@__namedic_last_method__, *(names + [options]))
    elsif !args.first.is_a?(Namedic)
      return @__to_namedify__ = args
    end

    @__to_namedify__ = false

    options = Hash[
      :optional => [],
      :alias    => {},
      :rest     => []
    ].merge(args.last.is_a?(Hash) ? args.pop : {})

    method = args.shift.to_sym
    names  = args

    refine_method method do |old, *args|
      old.call(*Namedic.arguments(names, options, *args))
    end
  end; alias named namedic

  def singleton_namedic (*args)
    raise ArgumentError, 'you have to pass at least one argument' if args.length == 0

    if args.first.nil?
      return unless @@__namedic_last_method__

      names, options = Namedic.definition(method(@@__namedic_last_method__))

      return singleton_namedic(@@__namedic_last_method__, *(names + [options]))
    elsif !args.first.is_a?(Namedic)
      return @@__to_namedify__ = args
    end

    @@__to_namedify__ = false

    options = Hash[
      :optional => [],
      :alias    => {},
      :rest     => []
    ].merge(args.last.is_a?(Hash) ? args.pop : {})

    method = args.shift.to_sym
    names  = args

    refine_singleton_method method do |old, *args|
      old.call(*Namedic.arguments(names, options, *args))
    end
  end
end
