defmodule FilePair do
  defstruct count: nil, val: nil
end

defmodule AdventOfCode.Day9 do
  @day 9
  @suffix ""
  @input_file "inputs/day_#{@day}#{@suffix}.txt"

  def part_1() do
    @input_file
    |> read_file()
    |> build_stack()
    |> build_filesystem()
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.map(fn {val, i} -> i * val end)
    |> Enum.sum()
  end

  def part_2() do
    @input_file
    |> read_file()
    |> build_compressed_stack()
    |> then(fn val ->
      val
    end)
    |> Enum.reverse()
    |> build_compressed_filesystem()
    |> checksum()
  end

  defp read_file(file_name) do
    with {:ok, content} <- File.read(file_name) do
      content
      |> String.graphemes()
      |> Enum.map(fn string ->
        if String.contains?("0123456789", string) do
          String.to_integer(string)
        else
          nil
        end
      end)
      |> Enum.filter(&(not is_nil(&1)))
    end
  end

  defp build_stack(inputs, stack \\ :queue.new(), id \\ 0)
  defp build_stack([], stack, _), do: stack

  defp build_stack([file], stack, id) do
    id_string =
      1..file
      |> Enum.map(fn _ -> id end)
      |> :queue.from_list()

    :queue.join(stack, id_string)
  end

  defp build_stack(inputs, stack, id) do
    [file, free | tail] = inputs

    file =
      0..file
      |> Enum.filter(&(&1 > 0))
      |> Enum.map(fn _ ->
        id
      end)
      |> :queue.from_list()

    free =
      0..free
      |> Enum.filter(&(&1 > 0))
      |> Enum.map(fn _ ->
        -1
      end)
      |> :queue.from_list()

    stack =
      if :queue.len(file) > 0 do
        :queue.join(stack, file)
      else
        stack
      end

    stack =
      if :queue.len(free) do
        :queue.join(stack, free)
      else
        stack
      end

    build_stack(tail, stack, id + 1)
  end

  defp build_filesystem(stack, filesystem \\ [])

  defp build_filesystem(stack, filesystem) do
    case :queue.out(stack) do
      {{_, head}, stack} ->
        case head do
          -1 ->
            case :queue.out_r(stack) do
              {{:value, -1}, stack} ->
                stack = :queue.in_r(-1, stack)
                build_filesystem(stack, filesystem)

              {{:value, val}, stack} ->
                stack = :queue.in_r(val, stack)
                build_filesystem(stack, filesystem)

              {:empty, _} ->
                filesystem
            end

          val ->
            build_filesystem(stack, [val | filesystem])
        end

      {:empty, _} ->
        filesystem
    end
  end

  defp build_compressed_stack(inputs, stack \\ [], id \\ 0)
  defp build_compressed_stack([], stack, _), do: stack

  defp build_compressed_stack([file], stack, id) do
    if file > 0 do
      [%FilePair{count: file, val: id} | stack]
    else
      stack
    end
  end

  defp build_compressed_stack(inputs, stack, id) do
    [file, free | tail] = inputs

    stack =
      if file > 0 do
        [%FilePair{count: file, val: id} | stack]
      else
        stack
      end

    stack =
      if free > 0 do
        [%FilePair{count: free, val: nil} | stack]
      else
        stack
      end

    build_compressed_stack(tail, stack, id + 1)
  end

  defp first_fit(queue, space) do
    queue = Enum.reverse(queue)

    idx =
      queue
      |> Enum.find_index(fn val ->
        not is_nil(val.val) && val.count <= space
      end)

    case idx do
      nil ->
        {:no_match, nil}

      val ->
        match =
          queue
          |> Enum.at(val)

        out_list =
          queue
          |> List.replace_at(val, %FilePair{count: match.count, val: nil})
          |> Enum.reverse()

        {:match, {match, out_list}}
    end
  end

  def build_compressed_filesystem([head]) do
    [head]
  end

  def build_compressed_filesystem([head | tail]) do
    case head.val do
      nil ->
        case first_fit(tail, head.count) do
          {:no_match, _} ->
            [head | build_compressed_filesystem(tail)]

          {:match, {match, tail_without_match}} ->
            remaining = %FilePair{count: head.count - match.count, val: nil}
            [match | build_compressed_filesystem([remaining | tail_without_match])]
        end

      _ ->
        [head | build_compressed_filesystem(tail)]
    end
  end

  defp checksum(pairs) do
    pairs
    |> Enum.flat_map(fn %FilePair{count: count, val: val} ->
      List.duplicate(val, count)
    end)
    |> Enum.with_index()
    |> Enum.map(fn {val, idx} ->
      case val do
        nil -> 0
        _ -> val * idx
      end
    end)
    |> Enum.sum()
  end
end
