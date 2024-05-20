defmodule Mix.Tasks.Tokenize do
  @moduledoc """
  Usage: mix tokenize /tmp/teste.be
  """
  @shortdoc "Tokenize a sample file"

  use Mix.Task

  @impl Mix.Task
  def run([file_path]) do
    file_path
    |> BeamCherry.read_file_by_lines()
    |> BeamCherry.Tokenizer.call()
    |> IO.inspect()
  end

  def run([]) do
    IO.puts(@moduledoc)
    System.halt(1)
  end
end
