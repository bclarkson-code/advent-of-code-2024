defmodule Solution do
  @allowed %{
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

  def part_1() do
    read_file("setup/day_1_input.txt")
    |> Enum.map(&parse_words/1)
    |> Enum.sum()
  end

  def part_2() do
    read_file("setup/day_1_input.txt")
    |> Enum.map(&parse_digits/1)
    |> Enum.sum()
  end

  defp read_file(file_name) do
    file_name
    |> File.read!()
    |> String.split("\n", trim: true)
  end

  defp combine_first_and_last([]), do: 0

  defp combine_first_and_last(extracted) do
    first = List.first(extracted)
    last = List.last(extracted)
    first * 10 + last
  end

  defp extract_digits(line) do
    ~r/\d/
    |> Regex.scan(line)
    |> Enum.map(fn [val] -> String.to_integer(val) end)
  end

  defp extract_words(line) do
    @allowed
    |> Enum.flat_map(fn {word, value} ->
      Regex.scan(~r/#{word}/, line, return: :index)
      |> Enum.map(fn [{idx, _len}] -> {idx, value} end)
    end)
    |> Enum.sort()
    |> Enum.map(&elem(&1, 1))
  end

  defp parse_digits([]), do: 0

  defp parse_digits(line) do
    line
    |> extract_digits()
    |> combine_first_and_last()
  end

  defp parse_words([]), do: 0

  defp parse_words(line) do
    line
    |> extract_words()
    |> combine_first_and_last()
  end
end

out = Solution.part_1()
IO.puts(out)

out = Solution.part_2()
IO.puts(out)
