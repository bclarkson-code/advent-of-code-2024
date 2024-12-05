# lib/mix/tasks/solve.ex
defmodule Mix.Tasks.Solve do
  use Mix.Task

  @shortdoc "Solves a specific day's puzzle"
  def run([day]) do
    {day_num, _} = Integer.parse(day)
    AdventOfCode.solve_day(day_num)
  end

  def run([]) do
    IO.puts("Please provide a day number. Example: mix solve 1")
  end
end
