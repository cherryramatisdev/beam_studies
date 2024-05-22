defmodule BeamCherry.Compile do
  @tags %{
    u: 0,
    i: 1,
    a: 2,
    x: 3,
    f: 5
  }

  @opcodes %{label: 1, func_info: 2, return: 19, int_code_end: 3}

  import Bitwise

  @spec call(ast :: list(BeamCherry.Tokenizer.t())) :: {:ok} | {:err}
  def call(_ast) do
    beam_content =
      ["BEAM"] ++
        chunk(:code) ++
        chunk(:import) ++
        chunk(:export) ++
        chunk(:str) ++
        chunk(:atom, ["output"])

    bytes =
      ["FOR1", arr_byte_length(beam_content) |> to_be_bytes()] ++
        beam_content

    File.write(
      "output.beam",
      bytes |> Enum.join()
    )

    {:ok}
  end

  defp chunk(:code) do
    instruction_set = 0
    sub_size = 16
    opcode_max = 169
    label_count = 3
    function_count = 1

    chunk =
      [
        to_be_bytes(sub_size),
        to_be_bytes(instruction_set),
        to_be_bytes(opcode_max),
        to_be_bytes(label_count),
        to_be_bytes(function_count),
        <<@opcodes[:label]>>
      ] ++
        encode(@tags[:u], 1) ++
        [<<@opcodes[:func_info]>>] ++
        encode(@tags[:a], 1) ++
        encode(@tags[:a], 1) ++
        encode(@tags[:u], 0) ++
        [<<@opcodes[:label]>>] ++
        encode(@tags[:u], 2) ++
        [<<@opcodes[:return]>>] ++
        [<<@opcodes[:int_code_end]>>]

    ["Code", arr_byte_length(chunk) |> to_be_bytes()] ++ pad_chunk(chunk)
  end

  defp chunk(:import) do
    import_count = 0

    chunk = [to_be_bytes(import_count)]

    ["ImpT", arr_byte_length(chunk) |> to_be_bytes()] ++ pad_chunk(chunk)
  end

  defp chunk(:export) do
    export_count = 0

    chunk = [to_be_bytes(export_count)]

    ["ExpT", arr_byte_length(chunk) |> to_be_bytes()] ++ pad_chunk(chunk)
  end

  defp chunk(:str) do
    ["StrT", to_be_bytes(0)]
  end

  defp chunk(:atom, atoms) do
    chunk =
      [length(atoms) |> to_be_bytes()] ++
        Enum.map(atoms, fn x -> <<byte_size(x)>> end) ++ atoms

    ["AtU8", arr_byte_length(chunk) |> to_be_bytes()] ++ pad_chunk(chunk)
  end

  defp pad_chunk(chunk) do
    chunk_rem = rem(arr_byte_length(chunk), 4)

    if chunk_rem != 0 do
      chunk ++ [:binary.copy(<<0>>, 4 - chunk_rem)]
    else
      chunk
    end
  end

  @spec arr_byte_length([binary()]) :: integer()
  defp arr_byte_length(chunks), do: chunks |> Enum.join() |> byte_size()

  @spec to_be_bytes(integer()) :: binary()
  defp to_be_bytes(num) when is_integer(num), do: <<num::size(32)-big-integer>>

  @spec encode(integer(), integer()) :: [binary()]

  # TODO: Negative numbers
  defp encode(_, n) when n < 0, do: []

  defp encode(tag, n) when n < 16, do: [<<n <<< 4 ||| tag>>]

  # TODO: Large numbers
  defp encode(_, _), do: []
end
