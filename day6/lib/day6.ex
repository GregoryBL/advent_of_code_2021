defmodule Day6 do
  def read_input_file(name) do
    File.read!(name)
    |> String.trim()
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.frequencies()
    |> Map.to_list()
  end

  def advance_days(freqs, _full_days, num_days) when num_days == 0 do
    freqs
  end

  def advance_days(freqs, full_days, num_days) do
    advance_days(collapse_freqs(advance_fish_day(freqs, full_days)), full_days, num_days - 1)
  end

  def advance_fish_day(freqs, full_days) do
    Enum.flat_map(freqs, fn f -> advance_day(f, full_days) end)
  end

  def advance_day({day, freq}, full_days) do
    case day do
      0 -> [{full_days - 1, freq}, {full_days + 1, freq}]
      _ -> [{day - 1, freq}]
    end
  end

  def collapse_freqs(freqs) do
    Enum.reduce(freqs, %{}, fn {day, num}, acc ->
      {_old, new_map} =
        Map.get_and_update(acc, day, fn curr ->
          if curr == nil do
            {curr, num}
          else
            {curr, num + curr}
          end
        end)

      new_map
    end)
    |> Map.to_list()
  end

  def total_fish(freqs) do
    Enum.reduce(freqs, 0, fn {_day, num}, acc ->
      acc + num
    end)
  end

  def part1(freqs) do
    total_fish(advance_days(freqs, 7, 80))
  end

  def part2(freqs) do
    total_fish(advance_days(freqs, 7, 256))
  end

  def test_solution do
    test_input = read_input_file("test.txt")
    IO.puts("Answer Part1 = " <> "5934")
    IO.puts(part1(test_input))
    IO.puts("Answer Part2 = " <> "26984457539")
    IO.puts(part2(test_input))
  end

  def real_solution do
    test_input = read_input_file("input-6.txt")
    IO.puts(part1(test_input))
    IO.puts(part2(test_input))
  end

  def main do
    test_solution()
    real_solution()
  end
end
