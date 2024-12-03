defmodule Solution do
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
    [_ | tail] = row

    Enum.zip(row, tail)
    |> Enum.map(fn {l, r} -> l < r end)
    |> Enum.all?()
  end

  defp descending?(row) do
    [_ | tail] = row

    Enum.zip(row, tail)
    |> Enum.map(fn {l, r} -> l > r end)
    |> Enum.all?()
  end

  defp small_distance?(row) do
    [_ | tail] = row

    Enum.zip(row, tail)
    |> Enum.map(fn {l, r} -> abs(l - r) < 4 and abs(l - r) > 0 end)
    |> Enum.all?()
  end

  defp nearly_safe?(row) do
    {ascending, asc_used_at} = NearlyValid.check(row, &(&1 < &2))
    {descending, desc_used_at} = NearlyValid.check(row, &(&1 > &2))

    case {ascending, asc_used_at, descending, desc_used_at} do
      {0, nil, _, _} ->
        {small_distance, _} =
          NearlyValid.check(
            row,
            &(abs(&1 - &2) < 4 and abs(&1 - &2) > 0)
          )

        small_distance == 0

      {1, used_at, _, _} ->
        small_distance?(List.delete_at(row, used_at))

      {_, _, 0, nil} ->
        {small_distance, _} =
          NearlyValid.check(
            row,
            &(abs(&1 - &2) < 4 and abs(&1 - &2) > 0)
          )

        small_distance == 0

      {_, _, 1, used_at} ->
        small_distance?(List.delete_at(row, used_at))

      {_, _, _, _} ->
        false
    end
  end
end

defmodule NearlyValid do
  def check(list, func) do
    processed =
      list
      |> Enum.chunk_every(3, 1, :discard)
      |> Enum.scan({nil, nil, 0}, fn row, {_, used, idx} -> is_valid?(row, func, used, idx) end)

    n_invalid =
      processed
      |> Enum.reduce(
        0,
        fn {val, _, _}, acc ->
          if val do
            acc
          else
            acc + 1
          end
        end
      )

    used_at =
      processed
      |> Enum.reduce(
        nil,
        fn {_, val, _}, acc ->
          if not is_nil(val) do
            val
          else
            acc
          end
        end
      )

    {n_invalid, used_at}
  end

  defp is_valid?([a, b, c], func, used_at, idx) do
    case({func.(a, b), func.(a, c), used_at}) do
      {true, _, nil} -> {true, nil, idx + 1}
      {false, _, nil} -> {false, idx, idx + 1}
      {_, is_valid, used_at} -> {is_valid, used_at, idx + 1}
    end
  end
end

out = Solution.part_1()
IO.puts(out)

out = Solution.part_2()
IO.puts(out)
