defmodule D14 do
  def read_input_file(name) do
    [start, exps] =
      File.read!(name)
      |> String.trim()
      |> String.split("\n\n", trim: true)

    input = String.split(start, "", trim: true)

    expansions =
      exps
      |> String.split("\n", trim: true)
      |> Enum.map(fn l ->
        [templ, repl] = String.split(l, " -> ", trim: true)
        {String.split(templ, "", trim: true), repl}
      end)
      |> Enum.into(%{})

    {input, expansions}
  end

  def tick(b, _e, 0), do: b

  def tick(before, expansions, num) do
    IO.puts(num)

    aft =
      Enum.chunk_every(before, 2, 1)
      |> Enum.flat_map(fn e ->
        if length(e) != 2 do
          e
        else
          [a, b] = e
          [a, Map.get(expansions, [a, b])]
        end
      end)

    tick(aft, expansions, num - 1)
  end

  def run(start, expansions, num) do
    freqs =
      tick(start, expansions, num)
      |> Enum.frequencies()

    {max_l, max_n} =
      Enum.max_by(freqs, fn {l, n} ->
        n
      end)

    {min_l, min_n} =
      Enum.min_by(freqs, fn {l, n} ->
        n
      end)

    max_n - min_n
  end

  def part1({start, expansions}) do
    run(start, expansions, 10)
  end

  def part2({start, expansions}) do
    exp =
      expansions
      |> Map.keys()
      |> Enum.map(fn p ->
        {p, tick(start, expansions, 4) |> Enum.frequencies()}
      end)
      |> Enum.into(%{})

    res =
      tick(start, expansions, 4)
      |> Enum.chunk_every(2, 1)
      |> Enum.frequencies()
      |> Enum.reduce(%{}, fn {k, num}, acc ->
        kmap =
          if length(k) == 1 do
            %{Enum.at(k, 0) => 1}
          else
            Map.get(exp, k)
          end
          |> Enum.map(fn {k1, v} ->
            {k1, num * v}
          end)
          |> Enum.into(%{})

        Map.merge(acc, kmap, fn _key, v1, v2 ->
          v1 + v2
        end)
      end)
  end

  def test_solution do
    test_input = read_input_file("test.txt")
    IO.puts("Answer Part1 = " <> "1588")
    IO.inspect(part1(test_input))
    IO.puts("Answer Part2 = " <> "2188189693529")
    IO.inspect(part2(test_input))
  end

  def real_solution do
    input = read_input_file("input-9.txt")
    IO.puts(part1(input))
    # IO.inspect(part2(input))
  end

  def main do
    test_solution()
    real_solution()
  end
end
