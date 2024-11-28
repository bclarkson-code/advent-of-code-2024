defmodule Solution do
  defp read_file(file_name) do
    case File.read(file_name) do
      {:ok, data} ->
        data

      {:error, reason} ->
        IO.puts(reason)
        raise reason
    end
  end

  defp parse_digits([], total), do: total

  defp parse_digits(line, total) do
    numbers =
      Regex.scan(~r/\d/, line)
      |> Enum.map(fn [val] ->
        {parsed, _} = Integer.parse(val)
        parsed
      end)

    case numbers do
      [] ->
        total

      _ ->
        first = List.first(numbers)
        last = List.last(numbers)
        first * 10 + last + total
    end
  end

  defp parse_words([], total), do: total

  defp parse_words(line, total) do
    allowed = %{
      "0" => 0,
      "1" => 1,
      "2" => 2,
      "3" => 3,
      "4" => 4,
      "5" => 5,
      "6" => 6,
      "7" => 7,
      "8" => 8,
      "9" => 9,
      "zero" => 0,
      "one" => 1,
      "two" => 2,
      "three" => 3,
      "four" => 4,
      "five" => 5,
      "six" => 6,
      "seven" => 7,
      "eight" => 8,
      "nine" => 9
    }

    numbers =
      Enum.flat_map(allowed, fn {word, value} ->
        Regex.scan(~r/#{word}/, line, return: :index)
        |> Enum.map(fn [{start, _len}] -> {start, value} end)
      end)
      |> Enum.sort()
      |> Enum.map(fn {_idx, val} -> val end)

    case numbers do
      [] ->
        total

      _ ->
        first = List.first(numbers)
        last = List.last(numbers)
        first * 10 + last + total
    end
  end

  def part_1() do
    read_file("setup/day_1_input.txt")
    |> String.split(data, "\n")
    |> Enum.reduce(0, &parse_digits/2)
  end

  def part_2() do
    read_file("setup/day_1_input.txt")
    |> String.split("\n")
    |> Enum.reduce(0, &parse_words/2)
  end
end

out = Solution.part_1()
IO.puts(out)

out = Solution.part_2()
IO.puts(out)
