class Injector
	@content : String
	@delimiter : String
	@shell : String
	@@version : String = "0.1"

	def initialize(argv : Array(String))
		# If STDIN is a tty device, that means there was no input,
		# and it's trying to read from the user input. Instead,
		# we'll load an empty string.
		@content = (STDIN.gets_to_end unless STDIN.tty?) || ""
		@args = argv

		# Flags that require a parameter are listed here
		@param_flags = ['s', 'd']
		@param_flags_longform = ["shell", "delimiter"]

		# Flags that do not require a parameter are listed here
		@flags = ['t', 'v', 'h', 'b']
		@flags_longform = ["text", "version", "help", "block"]

		# Default settings
		@shell = ENV["SHELL"] || "/bin/sh"
		@should_execute = true
		@delimiter = "[!]"
		@block_mode = false
	end
	
	def run()
		# If no arguments are provided, print a version and exit.
		use_parameter('v', nil) unless @args.size >= 1

		parse_parameters()
		lines : Array(String)
		
		if @block_mode
			lines = [@content]
		else
			lines = @content.split('\n', remove_empty: true)
		end

		lines.each do |line|
			command = inject(line)
			if @should_execute
				exec_command(command)
			else
				puts command
			end
		end
		
	end

	def parse_parameters()
		# This variable will store how many of the elements in
		# @args are parameters. Used later to strip parameters off
		# the main command.
		num_arguments = 0

		# We will use this flag to keep track of two things - firstly,
		# if flags are passed in a block of single letters ("-fdav"),
		# only one parameter can be used. If more than one is used,
		# the command is invalid. Secondly, this allows us to not parse
		# the parameter if it has been used.
		param_used = false;

		# Injector#run guarantees that @args.size >= 1 here.
		(0...@args.size).each do |index|
			# If param_used was set true last iteration,
			# we are currently about to process a parameter.
			# We don't want to do that, of course, so we'll skip.
			if param_used
				param_used = false;
				next;
			end

			# Check to see if the first character of the argument
			# is a dash. If it is, we are parsing a flag.
			# This iterator will halt as soon as we are no longer
			# reading flags.
			if @args[index][0] == '-'
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
			else
				# This argument doesn't start with a dash. Also, because
				# the param_used flag wasn't set (code couldn't get here if
				# it was), this isn't a parameter. This means we have reached
				# the command body.

				num_arguments = index
				break
			end
		end
		
		# If the last argument starts with a dash, that means that there
		# was no command string provided. This is okay for things like --version
		if @args[-1][0] == '-'
			# We need to delete everything. There was no command.
			@args = [""]
			# Note that there's no command to execute.
			@should_execute = false
		else
			# There's still a command, so just prune the args off
			# the beginning.
			@args.delete_at(0, num_arguments)
		end
	end

	def use_parameter(name : String | Char, value : String | Nil)
		case name
		when "text", 't'
			@should_execute = false
		when "shell", 's'
			if value
				@shell = value
			end
		when "delimiter", 'd'
			if value
				@delimiter = value
			end
		when "version", 'v'
			printf "inject version #{@@version}\n"
			printf "written by Seth Hinz (shinzlet)\n"
			exit
		when "help", 'h'
			system "man inject"
			exit
		when "block", 'b'
			@block_mode = true
		end
	end

	def inject(content : String)
		# As this program accepts a shell command instead of just arguments,
		# we have to take our tokenized array, ["which", "looks", "like", "this"],
		# and rejoin it with whitespace. As terminals are whitespace-agnostic,
		# we don't have to worry about if the words were divided with tabs or spaces.
		# I'm using spaces here as that's generally what's desired. This step also
		# performs the substitution, replacing all instances of the delimiter
		# with whatever was piped into this bad boy.
		return @args.join(" ").gsub(@delimiter, content)

		# Surprisingly easy! Thanaaaanks, crystal <3
	end

	def exec_command(command : String)
		#system "#{@shell || "/bin/sh"} #{command}"
		args : Array(String) = ["-c", command]
		Process.run(command: @shell, args: args, output: STDOUT, error: STDERR)
	end
end

Injector.new(ARGV).run
