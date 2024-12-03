defmodule Solution do
  @day 4
  @suffix ""
  @input_file "setup/day_#{@day}#{@suffix}_input.txt"

  def part_1() do
    @input_file
    |> read_file
    |> Enum.map(&parse_row/1)
    |> Enum.map(fn {left, right} ->
      right
      |> Enum.count(fn val -> MapSet.member?(left, val) end)
      |> then(fn
        0 -> 0
        val -> 2 ** (val - 1)
      end)
    end)
    |> Enum.sum()
  end

  def part_2() do
    @input_file
    |> read_file
    |> Enum.map(&parse_row/1)
    |> Enum.map(fn {left, right} ->
      right
      |> Enum.count(fn val -> MapSet.member?(left, val) end)
    end)
    |> Enum.reduce({1, %{}}, &count_cards/2)
    |> then(fn {_, cards} ->
      cards
      |> Map.values()
      |> Enum.sum()
    end)
  end

  defp read_file(file_name) do
    file_name
    |> File.read!()
    |> String.split("\n", trim: true)
  end

  defp parse_row(row) do
    left =
      ~r/\:\s(.*)\s\|/
      |> Regex.scan(row)
      |> then(fn [[_, val]] -> val end)
      |> parse_nums
      |> MapSet.new()

    right =
      ~r/\|\s(.*)/
      |> Regex.scan(row)
      |> then(fn [[_, val]] -> val end)
      |> parse_nums
      |> MapSet.new()

    {left, right}
  end

  defp parse_nums(nums) do
    ~r/\d+/
    |> Regex.scan(nums)
    |> Enum.map(fn [num] -> String.to_integer(num) end)
  end

  defp count_cards(wins, {idx, cards}) do
    original = Map.get(cards, idx, 0) + 1
    cards = Map.put(cards, idx, original)

    case wins do
      0 ->
        {idx + 1, cards}

      num ->
        cards =
          (idx + 1)..(idx + num)
          |> Enum.reduce(cards, fn card, cards ->
            current = Map.get(cards, card, 0)
            Map.put(cards, card, current + original)
          end)

        {idx + 1, cards}
    end
  end
end

out = Solution.part_1()
IO.puts(out)

out = Solution.part_2()
IO.puts(out)
