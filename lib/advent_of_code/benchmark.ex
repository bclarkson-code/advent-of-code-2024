defmodule AdventOfCode.Benchmark do
  def run(day, runs \\ 10) do
    times =
      for _ <- 1..runs do
        {time, _} =
          :timer.tc(fn ->
            # Capture and discard output
            ExUnit.CaptureIO.capture_io(fn ->
              AdventOfCode.solve_day(day)
            end)
          end)

        # Convert to milliseconds
        time / 1000
      end

    mean = Enum.sum(times) / runs
    sorted_times = Enum.sort(times)
    min_time = List.first(sorted_times)
    max_time = List.last(sorted_times)

    # Calculate standard deviation
    variance =
      times
      |> Enum.map(fn x -> :math.pow(x - mean, 2) end)
      |> Enum.sum()
      |> Kernel./(runs)

    stddev = :math.sqrt(variance)

    IO.puts("\nBenchmark results for Day #{day}:")
    IO.puts("  Time (mean ± σ):     #{Float.round(mean, 1)} ms ± #{Float.round(stddev, 1)} ms")

    IO.puts(
      "  Range (min … max):   #{Float.round(min_time, 1)} ms … #{Float.round(max_time, 1)} ms    #{runs} runs"
    )
  end
end
