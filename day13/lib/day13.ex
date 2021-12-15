defmodule D13 do
  def read_input_file(name) do
    [points, folds] =
      File.read!(name)
      |> String.trim()
      |> String.split("\n\n", trim: true)

    pp =
      points
      |> String.split("\n", trim: true)
      |> Enum.map(fn l ->
        List.to_tuple(
          String.split(l, ",", trim: true)
          |> Enum.map(&String.to_integer/1)
        )
      end)

    ff =
      folds
      |> String.split("\n", trim: true)
      |> Enum.map(fn l ->
        List.to_tuple(
          String.replace_prefix(l, "fold along ", "")
          |> String.split("=", trim: true)
        )
      end)

    {pp, ff}
  end

  def fold(points, {"x", n}) do
    n = String.to_integer(n)

    Enum.map(points, fn {x, y} ->
      cond do
        x > n -> {2 * n - x, y}
        true -> {x, y}
      end
    end)
  end

  def fold(points, {"y", n}) do
    n = String.to_integer(n)

    Enum.map(points, fn {x, y} ->
      cond do
        y > n -> {x, 2 * n - y}
        true -> {x, y}
      end
    end)
  end

  def display(points) do
    blank =
      for _y <- 0..5 do
        for _x <- 0..39, do: " "
      end

    Enum.reduce(points, blank, fn {x, y}, acc ->
      List.update_at(acc, y, fn row ->
        List.replace_at(row, x, "*")
      end)
    end)
  end

  def part1({points, folds}) do
    fold(points, Enum.at(folds, 0))
    |> Enum.uniq()
    |> Enum.count()
  end

  def part2({points, folds}) do
    Enum.reduce(folds, points, fn f, acc ->
      fold(acc, f)
      |> Enum.uniq()
    end)
    |> display()
    |> Enum.zip()
    |> Enum.reverse()
  end

  def test_solution do
    test_input = read_input_file("test.txt")
    IO.puts("Answer Part1 = " <> "17")
    IO.inspect(part1(test_input))
    IO.puts("Answer Part2 = " <> "36")
    IO.inspect(part2(test_input))
  end

  def real_solution do
    input = read_input_file("input-7.txt")
    IO.puts(part1(input))
    IO.inspect(part2(input))
  end

  def main do
    test_solution()
    real_solution()
  end
end
