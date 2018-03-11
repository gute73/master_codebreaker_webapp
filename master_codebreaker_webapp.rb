require 'sinatra'
require 'sinatra/reloader' if development?

class CodeBreaker # The game mechanics
	attr_accessor :turn, :player, :board

	def initialize(player)
		@player = player
		@board = Board.new
		@turn = 1
		@secret_code = Array.new
		generate_code
	end

# Generates and returns the computer player's secret code
	def generate_code 
		color = ["green", "blue", "red", "purple", "yellow", "orange"]
		4.times do
			@secret_code.pop
		end
		4.times do
			@secret_code.push(color[Random.rand(0..5)])
		end
	end

	# Executes one turn
	def player_turn(peg1_guess, peg2_guess, peg3_guess, peg4_guess)
		@board.fill_code_row(@turn, peg1_guess, peg2_guess, peg3_guess, peg4_guess)
		match(peg1_guess, peg2_guess, peg3_guess, peg4_guess)
		@turn += 1
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
		if peg1 == @secret_code[0] 
			black_count += 1
			peg1_match = true
			code1_match = true
		end
		if peg2 == @secret_code[1]
			black_count += 1
			peg2_match = true
			code2_match = true
		end
		if peg3 == @secret_code[2]
			black_count += 1
			peg3_match = true
			code3_match = true
		end
		if peg4 == @secret_code[3]
			black_count += 1
			peg4_match = true
			code4_match = true
		end
		if !peg1_match
			if !code2_match && peg1 == @secret_code[1]
				white_count += 1
				code2_match = true
			elsif !code3_match && peg1 == @secret_code[2]
				white_count += 1
				code3_match = true
			elsif !code4_match && peg1 == @secret_code[3]
				white_count += 1
				code4_match = true
			end
		end
		if !peg2_match
			if !code1_match && peg2 == @secret_code[0]
				white_count += 1
				code1_match = true
			elsif !code3_match && peg2 == @secret_code[2]
				white_count += 1
				code3_match = true
			elsif !code4_match && peg2 == @secret_code[3]
				white_count += 1
				code4_match = true
			end
		end
		if !peg3_match
			if !code1_match && peg3 == @secret_code[0]
				white_count += 1
				code1_match = true
			elsif !code2_match && peg3 == @secret_code[1]
				white_count += 1
				code2_match = true
			elsif !code4_match && peg3 == @secret_code[3]
				white_count += 1
				code4_match = true
			end
		end		
		if !peg4_match
			if !code1_match && peg4 == @secret_code[0]
				white_count += 1
				code1_match = true
			elsif !code2_match && peg4 == @secret_code[1]
				white_count += 1
				code2_match = true
			elsif !code3_match && peg4 == @secret_code[2]
				white_count += 1
				code3_match = true
			end
		end
		@board.fill_key_row(@turn, black_count, white_count)
	end

	def winner? # Returns true if the player has won the game
		if @board.get_key_peg(@turn-1, 1) == "black" && @board.get_key_peg(@turn-1, 1) == @board.get_key_peg(@turn-1, 2) && @board.get_key_peg(@turn-1, 2) == @board.get_key_peg(@turn-1, 3) && @board.get_key_peg(@turn-1, 3) == @board.get_key_peg(@turn-1, 4)
			return true
		else
			return false
		end
	end

	def loser?
		return @turn > 12 && !winner?
	end

	def update_stats
		if winner?
			@player.wins += 1
			if @player.best > @turn-1 || @player.best == -1
				@player.best = @turn-1
			end 
		elsif loser?
			@player.losses += 1
		end
	end

end

class Board # Manages the creation and manipulation of the game board

	def initialize
		@row = Array.new(12)
		(0..11).each do |index|
			@row[index] = Hash.new
			@row[index][:code_peg] = ["black", "black", "black", "black"]
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
			self.fill_key_peg(row, "black")
		end
		white_pegs.times do
			self.fill_key_peg(row, "white")
		end
		empty_pegs = 4 - black_pegs - white_pegs
		empty_pegs.times do
			self.fill_key_peg(row, "empty")
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
new_player = Player.new(0, 0, -1)
game = CodeBreaker.new(new_player)
winner = false
loser = false

get '/' do
	erb :index, :locals => {:game => game, :player => game.player, :board => game.board, :winner => winner, :loser => loser}
end

post '/submitRow' do
	game.player_turn(params['peg1_guess'], params['peg2_guess'], params['peg3_guess'], params['peg4_guess'])
	if game.winner? || game.loser?
		game.winner? ? winner=true : loser=true
		game.update_stats
		game.board = Board.new
		game.turn = 1
		game.generate_code
	else
		winner = false
		loser = false
	end
	redirect '/'
end
