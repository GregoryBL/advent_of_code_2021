defmodule Day9 do
  def read_input_file(name) do
    File.read!(name)
    |> String.trim()
    |> String.split("\n", trim: true)
    |> Enum.map(fn l ->
      String.split(l, "", trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
  end

  def check_low(point) when length(point) == 3 do
    [a, b, c] = point

    cond do
      b < c and b < a -> 1
      true -> 0
    end
  end

  def check_low(point) when length(point) == 2 do
    [a, b] = point

    cond do
      b < a -> 1
      true -> 0
    end
  end

  defp find_low_points_1d(rows) do
    mask =
      chunk(rows)
      |> Enum.map(fn r -> Enum.map(r, &check_low/1) end)
  end

  def find_low_points(input) do
    mask = find_low_points_1d(input)

    other_axis_mask =
      Enum.zip(input)
      |> Enum.map(&Tuple.to_list/1)
      |> find_low_points_1d()
      |> Enum.zip()
      |> Enum.map(&Tuple.to_list/1)

    Enum.zip([mask, other_axis_mask])
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(fn [list1, list2] ->
      Enum.zip_with(list1, list2, fn a, b ->
        a * b
      end)
    end)
  end

  def find_low_points_value(input, mask) do
    [List.flatten(input), List.flatten(mask)]
    |> Enum.zip()
    |> Enum.reduce(0, fn {a, b}, acc ->
      case b do
        1 -> a + 1 + acc
        _ -> acc
      end
    end)
  end

  def map_to_regions(input) do
    map_to_zero_one(input)
    |> group_lines()
  end

  def map_to_zero_one(input) do
    map_2_level_array(input, fn p ->
      if p == 9 do
        0
      else
        1
      end
    end)
  end

  def group_lines(lines) do
    Enum.map(lines, fn line ->
      res =
        Enum.reduce(Enum.with_index(line), {[], 0}, fn {p, idx}, acc ->
          {curr, last} = acc

          case p do
            0 ->
              {curr, 0}

            1 ->
              next =
                case acc do
                  {[], _} -> [[idx]]
                  {l, 0} -> [[idx] | l]
                  {[first | rest], 1} -> [first ++ [idx] | rest]
                end

              {next, 1}
          end
        end)

      {row, _} = res
      Enum.reverse(row)
    end)
  end

  def process_line(chunks, active_groups) do
    IO.puts("process line")
    cs = Enum.map(chunks, fn c -> {c, length(c), c} end)
    IO.inspect(cs)
    IO.inspect(active_groups)

    chunks_after = Enum.reduce(cs, active_groups, &add_chunk_to_chunks/2)

    Enum.map(chunks_after, fn {_, size, next} ->
      {next, size, []}
    end)
  end

  def merge_chunks(fc, sc) do
    {fc_mat, fc_len, fc_next} = fc
    {sc_mat, sc_len, sc_next} = sc

    overlap =
      Enum.any?(fc_mat, fn d ->
        Enum.member?(sc_mat, d)
      end)

    if overlap do
      {
        {
          Enum.uniq(fc_mat ++ sc_mat),
          fc_len + sc_len,
          Enum.uniq(fc_next ++ sc_next)
        },
        nil
      }
    else
      {fc, sc}
    end
  end

  def add_chunk_to_chunks(chunk, chunks) do
    # We are pairwise merging each c in chunks to chunk
    # If we combine we update chunk (we consumed it)
    # If we don't combine we add it to the existing list of chunks
    #   in the accumulator
    {existing, new} =
      Enum.reduce(chunks, {[], chunk}, fn c, {existing, new} ->
        {n_new, old} = merge_chunks(new, c)

        case old do
          # We combined
          nil -> {existing, n_new}
          # We didn't combine, so add c to existing and keep new the same
          _ -> {[c | existing], new}
        end
      end)

    [new | existing]
  end

  def find_sizes(lines, all) do
    # A currently active looks like {[points in last row], total_size}
    # acc = {[currently_active, [completed_sizes]}
    Enum.reduce(lines, {[], []}, fn l, [active, completed] ->
      nil
      # Enum.map(l, )
    end)
  end

  def chunk(rows) do
    Enum.map(rows, fn r ->
      Enum.chunk_every([10000 | r], 3, 1)
    end)
  end

  def map_2_level_array(arr, f) do
    Enum.map(arr, fn line ->
      Enum.map(line, fn p -> f.(p) end)
    end)
  end

  def part1(input) do
    mask = find_low_points(input)
    find_low_points_value(input, mask)
  end

  def part2(input) do
    map_to_regions(input)
    |> Enum.reduce([], &process_line/2)
    |> Enum.map(fn {_, size, _} -> size end)
    |> Enum.sort()
    |> Enum.take(-3)
    |> Enum.product()
  end

  def test_solution do
    test_input = read_input_file("test.txt")
    IO.puts("Answer Part1 = " <> "15")
    IO.puts(part1(test_input))
    IO.puts("Answer Part2 = " <> "1134")
    IO.puts(part2(test_input))
  end

  def real_solution do
    test_input = read_input_file("input-3.txt")
    IO.puts(part1(test_input))
    IO.puts(part2(test_input))
  end

  def main do
    test_solution()
    real_solution()
  end
end
