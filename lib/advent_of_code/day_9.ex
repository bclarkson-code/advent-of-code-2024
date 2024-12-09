defmodule AdventOfCode.Day9 do
  @day 9
  @suffix ""
  @input_file "inputs/day_#{@day}#{@suffix}.txt"

  def part_1() do
    @input_file
    |> read_file()
    |> build_stack()
    |> then(fn val ->
      val
      |> :queue.to_list()
      |> to_string()

      val
    end)
    |> build_filesystem()
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.map(fn {val, i} -> i * val end)
    |> Enum.sum()
  end

  def part_2() do
    grid = @input_file |> read_file()
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
      id
      |> to_string()
      |> String.duplicate(file)
      |> String.graphemes()
      |> :queue.from_list()

    :queue.join(stack, id_string)
  end

  defp build_stack(inputs, stack, id) do
    [file, free | tail] = inputs

    id_string =
      id
      |> to_string()
      |> String.duplicate(file)
      |> String.slice(0..file)
      |> String.graphemes()
      |> :queue.from_list()

    free_string =
      "."
      |> String.duplicate(free)
      |> String.graphemes()
      |> :queue.from_list()

    stack = :queue.join(stack, id_string)
    stack = :queue.join(stack, free_string)

    build_stack(tail, stack, id + 1)
  end

  defp build_filesystem(stack, filesystem \\ [])

  defp build_filesystem(stack, filesystem) do
    case :queue.out(stack) do
      {{_, head}, stack} ->
        case head do
          "." ->
            case :queue.out_r(stack) do
              {{:value, "."}, stack} ->
                stack = :queue.in_r(".", stack)
                build_filesystem(stack, filesystem)

              {{:value, val}, stack} ->
                stack = :queue.in_r(val, stack)
                build_filesystem(stack, filesystem)

              {:empty, _} ->
                filesystem
            end

          _ ->
            head = String.to_integer(head)
            build_filesystem(stack, [head | filesystem])
        end

      {:empty, _} ->
        filesystem
    end
  end
end
