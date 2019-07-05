class Injector
	def initialize(argv : Array(String))
		# If STDIN is a tty device, that means there was no input,
		# and it's trying to read from the user input. Instead,
		# we'll load an empty string.
		@content = (STDIN.gets_to_end unless STDIN.tty?) || ""
		@args = argv

		# This is the variable that will hold the subsituted command
		# after we finish parsing and injecting.
		@command_string = ""
		
		# Flags that require a parameter are listed here
		@param_flags = ['s', 'd']
		@param_flags_longform = ["shell", "delimeter"]

		# Flags that do not require a parameter are listed here
		@flags = ['t']
		@flags_longform = ["text"]

		# Default settings
		@shell = ENV["SHELL"] || "/bin/sh"
		@should_execute = true
	end
	
	def run()
		abort("No command provided!") unless @args.size >= 1
		parse_parameters()
		inject()
		exec_command() if @should_execute
	end

	def parse_parameters()
		# This variable will store how many of the elements in
		# @args are parameters. Used later to strip parameters off
		# the main command.
		num_params = 0
		# Injector#run guarantees that @args.size >= 1 here.
		(0...@args.size).each do |index|
			# We will use this flag to keep track of two things - firstly,
			# if flags are passed in a block of single letters ("-fdav"),
			# only one parameter can be used. If more than one is used,
			# the command is invalid. Secondly, this allows us to not parse
			# the parameter if it has been used.
			param_used = false;

			# Check to see if the first character of the argument
			# is a dash. If it is, we are parsing a flag.
			# This iterator will halt as soon as we are no longer
			# reading flags.
			if @args[index][0] == '-'
				# If param_used was set true last iteration,
				# we are currently about to process a parameter.
				# We don't want to do that, of course, so we'll skip.
				if param_used
					param_used = false;
					next;
				end

				# It was guaranteed that there was at least one
				# character in this argument, but we have to
				# make sure there is a second.
				if @args[index].size > 1
					# If the next character is also a dash,
					# this is a longform flag name.
					if @args[index][1] == '-'
						# Sanitize the flagname: "--flag" -> "flag"
						sanitized = @args[index][2..-1]
						if @param_flags_longform.includes? sanitized
							# This flag requires a parameter
							if @args.size > index + 1
								# There are enough args for a
								# parameter to be used.
								use_parameter(sanitized, @args[index + 1])
								# Mark that we have used up
								# a parameter.
								param_used = true
								# We're done processing this flag
								next
							end
						elsif @flags_longform.includes? sanitized
							# This flag doesn't need a parameter
							use_parameter(sanitized, nil)
							next
						else
							# This is an invalid flag
							abort("Flag '#{sanitized}' is unrecognized.")
						end
					else
						# Sanitize the flags: "-sUg" -> "sUg"
						sanitized = @args[index][1..-1]

						# A block of single-letter flags can have
						# at most one parameter: "-dsv param".
						# If more than one of those flags
						# requires a parameter, the command is invalid.

						# If there are multiple single-letter
						# flags, we deal with them one-by-one.
						sanitized.each_char do |letter|
							if @param_flags.includes? letter
								# This flag requires a parameter.

								if param_used
									# We can only provide one parameter
									# per flag block. This is invalid.
									abort("Flag block '#{sanitized}' requires multiple parameters.")
								end

								if @args.size > index + 1
									# There are enough args for
									# a parameter to be used.
									use_parameter(letter, @args[index + 1])
									# Mark that we have used up
									# the parameter.
									param_used = true;
									next
								else
									# There are insufficent args
									# to provide a parameter.
									abort("No parameter given for flag #{letter}.")
								end
							elsif @flags.includes? letter
								# This flag doesn't need a parameter
								use_parameter(letter, nil)
								next
							else
								# This is an invalid flag
								abort("Flag '#{letter}' is unrecognized.")
							end
						end
					end
				else
					# To reach this point in execution,
					# one of the arguments was a bare dash. ('-')
					abort("Argument #{index} malformed!")
				end
			end
		end
	end

	def use_parameter(name : String | Char, value : String | Nil)
		puts "#{name} : #{value || "nil"}"
	end

	def inject()
		# As this program accepts a shell command instead of just arguments,
		# we have to take our tokenized array, ["which", "looks", "like", "this"],
		# and rejoin it with whitespace. As terminals are whitespace-agnostic,
		# we don't have to worry about if the words were divided with tabs or spaces.
		# I'm using spaces here as that's generally what's desired.
		@command_string = @args.join(" ")


	end

	def exec_command()
	end
end

Injector.new(ARGV).run
