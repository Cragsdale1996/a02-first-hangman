defmodule HangmanTest do
  use ExUnit.Case
  doctest Hangman

  test "Dictionary module seccessfully imported" do
    assert Dictionary.random_word() |> is_binary()
  end
end
