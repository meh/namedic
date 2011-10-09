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
	@warn = true

	def self.warn (value)
		@warn = value
	end

	def self.warn?
		@warn
	end

	def initialize (name)
		@name = name.to_sym
	end

	def to_sym
		@name
	end

	def self.normalize (*args)
		options = Hash[
			:optional => [],
			:alias    => {},
			:rest     => []
		].merge(args.last.is_a?(Hash) ? args.pop : {})

		method = args.shift.to_sym
		names  = args

		options[:optional] = Hash[if options[:optional].is_a?(Range)
			names[options[:optional]]
		elsif options[:optional].is_a?(Hash)
			[options[:optional]]
		else
			options[:optional]
		end.map {|opt|
			if opt.is_a?(Hash)
				opt.to_a
			else
				[[opt, nil]]
			end
		}.flatten(1)]

		return method, names, options
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
			elsif name.is_a?(Integer) && !parameters[names[name - 1]].is_a?(Integer)
				parameters[names[name - 1]] = value
				parameters.delete(name)
			end
		}

		# check if there are unknown parameters
		parameters.keys.each {|parameter|
			raise ArgumentError, "#{parameter} is an unknown parameter" unless names.member?(parameter)
		}

		# check for missing required parameters
		(names - parameters.keys - options[:optional].keys).tap {|required|
			raise ArgumentError, "the following required parameters are missing: #{required.join(', ')}" unless required.empty?
		} unless options[:optional] == true

		all_optional_after = names.length - names.reverse.take_while {|name|
			options[:optional].has_key?(name) && !parameters.has_key?(name)
		}.length

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
				if index < all_optional_after
					warn 'keep in mind that optionals between two arguments will have nil as value' if Namedic.warn?
				end

				if options[:optional][name].nil? && index >= all_optional_after
					break
				end

				args << options[:optional][name]
			end
		}

		args
	end

	def self.definition (method)
		names   = []
		options = { :rest => [], :optional => [] }

		if method.respond_to? :parameters
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
		else
			if method.arity > 0
				names.push(*(1 .. method.arity))
			end
		end

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
			if @__namedic_last_method__
				names, options = Namedic.definition(instance_method(@__namedic_last_method__))
				namedic(Namedic.new(@__namedic_last_method__), *(names + [options]))
			end; true
		elsif !args.first.is_a?(Namedic)
			@__to_namedify__ = args
		end and return

		@__to_namedify__ = false

		method, names, options = Namedic.normalize(*args)

		instance_method(method).tap {|m|
			raise ArgumentError, 'method arity mismatch' if m.arity > 0 && m.arity != names.length
		}

		refine_method method do |old, *args, &block|
			old.call(*Namedic.arguments(names, options, *args), &block)
		end

		nil
	end; alias named namedic

	def singleton_namedic (*args)
		raise ArgumentError, 'you have to pass at least one argument' if args.length == 0

		if args.first.nil?
			if defined?(@@__namedic_last_method__) && @@__namedic_last_method__
				names, options = Namedic.definition(method(@@__namedic_last_method__))
				singleton_namedic(Namedic.new(@@__namedic_last_method__), *(names + [options]))
			end; true
		elsif !args.first.is_a?(Namedic)
			@@__to_namedify__ = args
		end and return

		@@__to_namedify__ = false

		method, names, options = Namedic.normalize(*args)

		method(method).tap {|m|
			raise ArgumentError, 'method arity mismatch' if m.arity > 0 && m.arity != names.length
		}

		refine_singleton_method method do |old, *args, &block|
			old.call(*Namedic.arguments(names, options, *args), &block)
		end

		nil
	end
end
