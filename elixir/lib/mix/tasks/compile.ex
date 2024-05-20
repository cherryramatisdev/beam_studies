defmodule Mix.Tasks.Beam.Compile do
  @moduledoc """
  Usage: mix beam.compile /tmp/teste.be
  """
  @shortdoc "Compile a sample file"

  use Mix.Task

  @impl Mix.Task
  def run([file_path]) do
    file_path
    |> BeamCherry.read_file_by_lines()
    |> BeamCherry.Tokenizer.call()
    |> BeamCherry.Compile.call()
  end

  def run([]) do
    IO.puts(@moduledoc)
    System.halt(1)
  end
end
