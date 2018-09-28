defmodule Hangman do
  @moduledoc """
  Hangman game API. Implementation is built out in
  Hangman.Game
  """

  alias Hangman.Game
  
  defdelegate new_game(),             to: Game
  defdelegate tally(game),            to: Game
  defdelegate make_move(game, guess), to: Game

end
