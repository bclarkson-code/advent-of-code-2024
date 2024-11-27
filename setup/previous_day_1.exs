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

  defp first_occurrence([], _values), do: nil

  defp first_occurrence([head | tail], values) do
    if String.contains?(values, head) do
      head
    else
      first_occurrence(tail, values)
    end
  end

  defp parse_digits(line, total) do
    digits = "0123456789"
    line = String.graphemes(line)

    first = first_occurrence(line, digits)
    last = first_occurrence(Enum.reverse(line), digits)

    with f when not is_nil(f) <- first,
         l when not is_nil(l) <- last do
      combined = f <> l

      case Integer.parse(combined) do
        {current, _} -> total + current
        :error -> total
      end
    else
      _ -> total
    end
  end

  defp parse_words([], total), do: nil

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

    allowed_pattern = ~r/\d|zero|one|two|three|four|five|six|seven|eight|nine/
    matches = Regex.scan(allowed_pattern, line)
    IO.puts("#{matches}")

    case matches do
      [first | _] -> first
      nil -> first = nil
    end

    case Enum.reverse(matches) do
      [last | _] -> last
      nil -> last = nil
    end

    first = Map.get(allowed, first)
    last = Map.get(allowed, last)

    with f when not is_nil(f) <- first,
         l when not is_nil(l) <- last do
      combined = f <> l

      case Integer.parse(combined) do
        {current, _} -> total + current
        :error -> total
      end
    else
      _ -> total
    end
  end

  def part_1() do
    data = read_file("setup/day_1_input.txt")

    String.split(data, "\n")
    |> Enum.reduce(0, &parse_digits/2)
  end

  def part_2() do
    data = read_file("setup/day_1_input.txt")

    allowed =
      String.split(data, "\n")
      |> Enum.reduce(0, &parse_words/2)
  end
end

out = Solution.part_1()
IO.puts(out)

out = Solution.part_2()
IO.puts(out)
