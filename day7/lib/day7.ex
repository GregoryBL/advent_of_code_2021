defmodule Day7 do
  def read_input_file(name) do
    File.read!(name)
    |> String.trim()
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)

    # |> Enum.frequencies()
  end

  def median(nums) do
    sorted = Enum.sort(nums)
    len = length(sorted)
    Enum.at(sorted, floor(len / 2) - 1)
  end

  def part1(nums) do
    center = median(nums)

    Enum.reduce(nums, 0, fn n, acc ->
      acc + abs(n - center)
    end)
  end

  def find_best_increasing(freqs, mx) do
    # Probably should nil and handle it but lazy
    Enum.reduce(0..mx, 100_000_000_000_000, fn n, acc ->
      cost = find_fuel_cost(freqs, n)

      if cost < acc do
        cost
      else
        acc
      end
    end)
  end

  def find_fuel_cost(freqs, center) do
    Enum.reduce(freqs, 0, fn {num, freq}, acc ->
      acc + Enum.sum(0..abs(center - num)) * freq
    end)
  end

  def part2(nums) do
    freqs = Enum.frequencies(nums)
    # This is arbitrary because I couldn't look up the
    #  way to get the max of a list and didn't feel like
    # reducing it.
    mx = 10000
    find_best_increasing(freqs, mx)
  end

  def test_solution do
    test_input = read_input_file("test.txt")
    IO.puts("Answer Part1 = " <> "37")
    IO.puts(part1(test_input))
    IO.puts("Answer Part2 = " <> "168")
    IO.puts(part2(test_input))
  end

  def real_solution do
    test_input = read_input_file("input.txt")
    IO.puts(part1(test_input))
    IO.puts(part2(test_input))
  end

  def main do
    test_solution()
    real_solution()
  end
end
