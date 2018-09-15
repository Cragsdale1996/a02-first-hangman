defmodule Hangman.Game do
    @moduledoc """
    Hangman game backend.
    """

    alias Hangman.Game.State

    def new_game() do
        %State{}
    end

    def tally(_game) do
        :tally
    end

    def make_move(_game, _guess) do
        :make_move
    end
    
end