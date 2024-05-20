defmodule BeamCherry do
  def read_file_by_lines(path) do
    {:ok, content} = File.read(path)

    content
    |> String.trim()
    |> String.split("\n")
  end
end
