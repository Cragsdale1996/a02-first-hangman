defmodule Hangman do
  @moduledoc """
  Hangman game API. Implementation is built out in
  Hangman.Game
  """

  alias Hangman.Game
  
  @doc """
  Creates a default game state for Hangman, fetching a random word from the 
  Dictionary module. This state will be transformed based on it's attributes
  and guesses made by the player.
  """
  defdelegate new_game(),             to: Game

  @doc """
  Creates a tally for the game, derived from the game's state. It is the foundation 
  of the game's interface to the player. It provides additional useful information, 
  and restricts unnecessary information (doesn't contain the word).
  """
  defdelegate tally(game),            to: Game

  @doc """
  Transforms the game's state based on it's attributes and the guess made by the player.
  Returns a new state and the tally for this new state in a tuple.
  """
  defdelegate make_move(game, guess), to: Game

end
