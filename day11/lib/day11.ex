defmodule D11 do
  def read_input_file(name) do
    File.read!(name)
    |> String.trim()
    |> String.split("\n", trim: true)
    |> Enum.map(fn l ->
      String.split(l, "", trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
  end

  def produce_input_map(input) do
    Enum.reduce(Enum.with_index(input), %{}, fn {line, v_idx}, acc ->
      Enum.map(Enum.with_index(line), fn {p, h_idx} ->
        {{h_idx, v_idx}, p}
      end)
      |> Enum.into(%{})
      |> Map.merge(acc)
    end)
  end

  def bump_all(m) do
    Map.map(m, fn {a, b} -> b + 1 end)
  end

  def merge_maps_add(m1, m2) do
    Map.merge(m1, m2, fn _k, v1, v2 ->
      v1 + v2
    end)
  end

  def merge_maps_zero(m1, m2) do
    Map.merge(m1, m2, fn _k, _v1, _v2 ->
      0
    end)
  end

  def flash_effect_coord_map({x, y}) do
    xs =
      case x do
        0 -> [0, 1]
        9 -> [8, 9]
        n -> [n - 1, n, n + 1]
      end

    ys =
      case y do
        0 -> [0, 1]
        9 -> [8, 9]
        n -> [n - 1, n, n + 1]
      end

    for(
      a <- xs,
      b <- ys,
      do: {a, b}
    )
    |> List.delete({x, y})
    |> Enum.map(fn c -> {c, 1} end)
    |> Enum.into(%{})
  end

  def do_flashes(flash_map, m) do
    flash_adds =
      flash_map
      |> Enum.map(fn {c, _v} ->
        flash_effect_coord_map(c)
      end)
      |> Enum.reduce(%{}, &merge_maps_add/2)

    merge_maps_add(m, flash_adds)
  end

  def find_flashes(m), do: find_flashes(m, m)

  def find_flashes(m, original_m, prev \\ 0) do
    flash_map =
      Enum.filter(m, fn {_c, v} ->
        v > 9
      end)

    num_flashes = length(flash_map)

    if num_flashes > prev do
      find_flashes(do_flashes(flash_map, original_m), original_m, num_flashes)
    else
      {Enum.into(flash_map, %{}), num_flashes}
    end
  end

  def zero_flashed(m, flash_map) do
    merge_maps_zero(m, flash_map)
  end

  def run_tick(m, 0), do: 0

  def run_tick(m, num_times) do
    bumped = bump_all(m)

    {flash_map, num_flashes} = find_flashes(bumped)

    later_flashes =
      do_flashes(flash_map, bumped)
      |> zero_flashed(flash_map)
      |> run_tick(num_times - 1)

    later_flashes + num_flashes
  end

  def run_tick_break_if_all(m, 0), do: 0

  def run_tick_break_if_all(m, num_times) do
    bumped = bump_all(m)

    {flash_map, num_flashes} = find_flashes(bumped)

    if num_flashes == 100 do
      num_times - 1
    else
      later_flashes =
        do_flashes(flash_map, bumped)
        |> zero_flashed(flash_map)
        |> run_tick_break_if_all(num_times - 1)
    end
  end

  def part1(input) do
    m = produce_input_map(input)
    run_tick(m, 100)
  end

  def part2(input) do
    m = produce_input_map(input)

    num = 1000
    left = run_tick_break_if_all(m, num)

    num - left
  end

  def test_solution do
    test_input = read_input_file("test.txt")
    IO.puts("Answer Part1 = " <> "1656")
    IO.inspect(part1(test_input))
    IO.puts("Answer Part2 = " <> "195")
    IO.inspect(part2(test_input))
  end

  def real_solution do
    test_input = read_input_file("input-5.txt")
    IO.puts(part1(test_input))
    IO.puts(part2(test_input))
  end

  def main do
    test_solution()
    real_solution()
  end
end
