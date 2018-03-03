require 'sinatra'
require 'sinatra/reloader' if development?

class GameLogic # The game logic
	def initialize(player)
		@player = player
		@board = Board.new
		@turn = 0
		@secret_code = Array.new
		generate_code
	end

	def play # Plays one game of Master Codebreaker
		while 1
			@turn += 1
			player_turn

			if winner?
#				puts "You are victorious in #{@turn} turn(s)!\n"
				@player.wins += 1
				if @player.best > @turn || @player.best == -1
					@player.best = @turn
				end
				return 
			end
			if @turn >= 12
#				puts "You have been defeated!\n"
				@player.losses += 1
				return
			end
		end
	end

	private

	def generate_code # Generates and returns the computer player's secret code
		color = ["G", "B", "R", "P", "Y", "O"]
		4.times do
			@secret_code.push(color[Random.rand(0..5)])
		end
	end

	def player_turn # Executes one turn
		begin
#			puts "Guess the secret code. The colors are red, green, blue, yellow,"
#			puts "purple, and orange. Colors may be used more than once."
#			puts
#			print "Peg 1: "
			peg1_guess = gets.chomp.upcase
#			print "Peg 2: "
			peg2_guess = gets.chomp.upcase
#			print "Peg 3: "
			peg3_guess = gets.chomp.upcase
#			print "Peg 4: "
			peg4_guess = gets.chomp.upcase
			raise ArgumentError if guess_error?(peg1_guess) || guess_error?(peg2_guess) || guess_error?(peg3_guess) || guess_error?(peg4_guess)
		rescue
#			puts "You must enter one of the six listed colors."
			retry
		end

		@board.fill_code_row(@turn, peg1_guess[0], peg2_guess[0], peg3_guess[0], peg4_guess[0])
		match(peg1_guess, peg2_guess, peg3_guess, peg4_guess)

	end

	def guess_error?(guess) # Returns true if the user input an invalid guess
		return !(guess == "RED" || guess == "BLUE" || guess == "GREEN" || guess == "ORANGE" || guess == "YELLOW" || guess == "PURPLE" || guess == "R" || guess == "B" || guess == "G" || guess == "O" || guess == "Y" || guess == "P")
	end

	# Determines if any of the player's guesses match the 
	# secret code.  Assigns key pegs as appropriate.
	def match(peg1, peg2, peg3, peg4)
		black_count = 0
		white_count = 0
		peg1_match = false
		peg2_match = false
		peg3_match = false
		peg4_match = false
		code1_match = false
		code2_match = false
		code3_match = false
		code4_match = false
		if peg1[0] == @secret_code[0] 
			black_count += 1
			peg1_match = true
			code1_match = true
		end
		if peg2[0] == @secret_code[1]
			black_count += 1
			peg2_match = true
			code2_match = true
		end
		if peg3[0] == @secret_code[2]
			black_count += 1
			peg3_match = true
			code3_match = true
		end
		if peg4[0] == @secret_code[3]
			black_count += 1
			peg4_match = true
			code4_match = true
		end
		if !peg1_match
			if !code2_match && peg1[0] == @secret_code[1]
				white_count += 1
				code2_match = true
			elsif !code3_match && peg1[0] == @secret_code[2]
				white_count += 1
				code3_match = true
			elsif !code4_match && peg1[0] == @secret_code[3]
				white_count += 1
				code4_match = true
			end
		end
		if !peg2_match
			if !code1_match && peg2[0] == @secret_code[0]
				white_count += 1
				code1_match = true
			elsif !code3_match && peg2[0] == @secret_code[2]
				white_count += 1
				code3_match = true
			elsif !code4_match && peg2[0] == @secret_code[3]
				white_count += 1
				code4_match = true
			end
		end
		if !peg3_match
			if !code1_match && peg3[0] == @secret_code[0]
				white_count += 1
				code1_match = true
			elsif !code2_match && peg3[0] == @secret_code[1]
				white_count += 1
				code2_match = true
			elsif !code4_match && peg3[0] == @secret_code[3]
				white_count += 1
				code4_match = true
			end
		end		
		if !peg4_match
			if !code1_match && peg4[0] == @secret_code[0]
				white_count += 1
				code1_match = true
			elsif !code2_match && peg4[0] == @secret_code[1]
				white_count += 1
				code2_match = true
			elsif !code3_match && peg4[0] == @secret_code[2]
				white_count += 1
				code3_match = true
			end
		end
		@board.fill_key_row(@turn, black_count, white_count)
	end

	def winner? # Returns true if the player has won the game
		if @board.get_key_peg(@turn, 1) == "B" && @board.get_key_peg(@turn, 1) == @board.get_key_peg(@turn, 2) && @board.get_key_peg(@turn, 2) == @board.get_key_peg(@turn, 3) && @board.get_key_peg(@turn, 3) == @board.get_key_peg(@turn, 4)
			return true
		else
			return false
		end
	end

end

class Board # Manages the creation and manipulation of the game board

	def initialize
		@row = Array.new(12)
		(0..11).each do |index|
			@row[index] = Hash.new
			@row[index][:code_peg] = []
			@row[index][:key_peg] = []
		end
	end

	# Fills the code pegs of one row
	def fill_code_row(row, peg1, peg2, peg3, peg4)
		@row[row-1][:code_peg] = [peg1, peg2, peg3, peg4]
	end

	# Fills the key pegs of one row
	def fill_key_row(row, black_pegs, white_pegs)
		black_pegs.times do
			self.fill_key_peg(row, "B")
		end
		white_pegs.times do
			self.fill_key_peg(row, "W")
		end
		empty_pegs = 4 - black_pegs - white_pegs
		empty_pegs.times do
			self.fill_key_peg(row, "E")
		end
	end

	# Assign a key peg (black, white, or empty) to the next empty slot
	def fill_key_peg(row, value)
		@row[row-1][:key_peg].push(value)
	end

	# Returns the value of a code peg from a given row
	def get_code_peg(row, peg_num)
		@row[row-1][:code_peg][peg_num-1]
	end

	# Returns the value of a key peg from a given row
	def get_key_peg(row, peg_num)
		@row[row-1][:key_peg][peg_num-1]
	end
end

Player = Struct.new(:wins, :losses, :best)

Code = Struct.new(:code1, :code2, :code3, :code4)

player = Player.new(0, 0, -1)
=begin
play_again = true
while play_again
#	puts "Let's play!"
 	game = GameLogic.new(player)
	game.play

	begin
		keep_playing = gets.chomp
		raise ArgumentError if keep_playing != "yes" && keep_playing != "Yes" && keep_playing != "no" && keep_playing != "No"
	rescue
		puts "Please enter either 'yes' or 'no'. "
		retry
	end
	play_again = (keep_playing == "yes" || keep_playing == "Yes") ? true : false
end

=end

get '/' do
	erb :index, :locals => {}
end