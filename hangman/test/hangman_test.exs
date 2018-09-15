defmodule HangmanTest do
  use ExUnit.Case
  doctest Hangman

  test "Dictionary module seccessfully imported" do
    assert Dictionary.random_word() |> is_binary()
  end

  test "new_game returns default state" do
    state = Hangman.new_game()

    assert state.turns_left == 7
    assert state.status == :initializing
  end
end
