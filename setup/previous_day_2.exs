defmodule Solution do
  @day 2

  @suffix "_sample"

  @total %{"red" => 12, "green" => 13, "blue" => 14}
  def part_1() do
    read_file("setup/day_#{@day}#{@suffix}_input.txt")
    |> Enum.map(&parse_row/1)
    |> Enum.map(&too_big/1)
    |> Enum.reduce(0, fn game, acc ->
      if game.too_big do
        acc
      else
        acc + game.id
      end
    end)
  end

  def part_2() do
    read_file("setup/day_#{@day}#{@suffix}_input.txt")
    |> Enum.map(&parse_row/1)
    |> Enum.map(&fewest_cubes/1)
    |> Enum.reduce(0, fn count, acc ->
      power =
        count
        |> Map.values()
        |> Enum.product()

      acc + power
    end)
  end

  defp read_file(file_name) do
    file_name
    |> File.read!()
    |> String.split("\n", trim: true)
  end

  defp parse_row(row) do
    [id_string | [games_string]] = String.split(row, ":")

    {_, id} = parse_pair(id_string)
    id = String.to_integer(id)

    games = parse_games_string(games_string)

    %{:id => id, :games => games}
  end

  defp parse_pair(string) do
    string = String.trim(string, " ")
    [key | [value]] = String.split(string, " ")
    {key, value}
  end

  defp parse_games_string(games_string) do
    games_string
    |> String.split(";")
    |> Enum.map(&parse_single_game/1)
  end

  defp parse_single_game(game) do
    game
    |> String.split(", ")
    |> Enum.map(&parse_pair/1)
    |> Enum.map(fn {val, key} -> {key, String.to_integer(val)} end)
    |> Map.new()
  end

  defp too_big(game) do
    is_too_big =
      Map.get(game, :games)
      |> Enum.any?(fn pairs ->
        pairs
        |> Enum.any?(&pair_too_big?/1)
      end)

    Map.put(game, :too_big, is_too_big)
  end

  defp pair_too_big?({key, val}) do
    val > Map.get(@total, key)
  end

  defp fewest_cubes(game) do
    game.games
    |> Enum.flat_map(fn row -> Map.to_list(row) end)
    |> Enum.reduce(
      %{},
      fn {key, val}, acc ->
        current = Map.get(acc, key, 0)

        if val > current do
          Map.put(acc, key, val)
        else
          acc
        end
      end
    )
  end
end

out = Solution.part_1()
IO.puts(out)

out = Solution.part_2()
IO.puts(out)
