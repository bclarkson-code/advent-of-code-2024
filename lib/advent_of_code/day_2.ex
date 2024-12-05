defmodule AdventOfCode.Day2 do
  @day 2
  @suffix ""
  @input_file "inputs/day_#{@day}#{@suffix}.txt"

  def part_1() do
    @input_file
    |> read_file()
    |> Enum.map(&parse/1)
    |> Enum.map(&safe?/1)
    |> Enum.count(& &1)
  end

  def part_2() do
    @input_file
    |> read_file()
    |> Enum.map(&parse/1)
    |> Enum.map(&nearly_safe?/1)
    |> Enum.count(& &1)
  end

  defp read_file(file_name) do
    file_name
    |> File.read!()
    |> String.split("\n", trim: true)
  end

  defp parse(line) do
    line
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end

  defp safe?(row) do
    (ascending?(row) or
       descending?(row)) and small_distance?(row)
  end

  defp ascending?(row) do
    row
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.all?(fn [l, r] -> l < r end)
  end

  defp descending?(row) do
    row
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.all?(fn [l, r] -> l > r end)
  end

  defp close_to?([left, right]), do: close_to?(left, right)

  defp close_to?(left, right) do
    diff = abs(left - right)
    0 < diff and diff < 4
  end

  defp small_distance?(row) do
    row
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.all?(&close_to?/1)
  end

  defp nearly_safe?(row) do
    {ascending, asc_used_at} = NearlyValid.check(row, &(&1 < &2))
    {descending, desc_used_at} = NearlyValid.check(row, &(&1 > &2))

    case {ascending, asc_used_at, descending, desc_used_at} do
      {0, nil, _, _} -> nearly_close_to(row)
      {1, idx, _, _} -> row |> List.delete_at(idx) |> small_distance?
      {_, _, 0, nil} -> nearly_close_to(row)
      {_, _, 1, idx} -> row |> List.delete_at(idx) |> small_distance?
      _ -> false
    end
  end

  defp nearly_close_to(row) do
    row
    |> NearlyValid.check(&close_to?/2)
    |> elem(0)
    |> Kernel.==(0)
  end
end

defmodule NearlyValid do
  def check(list, func) do
    list
    |> Enum.chunk_every(3, 1, :discard)
    |> Enum.scan({nil, nil, 0}, fn row, {_, used, idx} ->
      is_valid?(row, func, used, idx)
    end)
    |> then(&{count_invalid(&1), get_used_at(&1)})
  end

  defp count_invalid(processed) do
    processed
    |> Enum.map(&elem(&1, 0))
    |> Enum.filter(&(not &1))
    |> Enum.count()
  end

  defp get_used_at(processed) do
    processed
    |> Enum.map(&elem(&1, 1))
    |> Enum.filter(&(not is_nil(&1)))
    |> List.first()
  end

  defp is_valid?([a, b, c], func, used_at, idx) do
    case({func.(a, b), func.(a, c), used_at}) do
      {true, _, nil} -> {true, nil, idx + 1}
      {false, _, nil} -> {false, idx, idx + 1}
      {_, is_valid, used_at} -> {is_valid, used_at, idx + 1}
    end
  end
end
