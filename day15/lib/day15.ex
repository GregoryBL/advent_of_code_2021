defmodule D15 do
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

  defmodule Choice do
    defstruct [:point, :cost]
  end

  def choice(point, cost) do
    %Choice{point: point, cost: cost}
  end

  ##########################################################

  # defmodule PQueue do
  #   defstruct val_map: %{}, min: nil
  # end

  # def new_pq(vm \\ %{}, min \\ nil) do
  #   %PQueue{val_map: vm, min: min}
  # end

  # def pq_add(pq, new) do
  #   {_c, {ev, _v, _p}} = new

  #   {_old, new_map} =
  #     Map.get_and_update(pq.val_map, ev, fn current_line ->
  #       if current_line == nil do
  #         {current_line, [new]}
  #       else
  #         {current_line, [new | current_line]}
  #       end
  #     end)

  #   new_pq(new_map, min(ev, pq.min))
  # end

  # def pq_next(pq) when pq.min == nil, do: {nil, pq}

  # def pq_next(pq) do
  #   {[first | rest], new_map} =
  #     Map.get_and_update(pq.val_map, pq.min, fn [first | rest] ->
  #       case rest do
  #         [] -> :pop
  #         _ -> {[first | rest], rest}
  #       end
  #     end)

  #   new_min =
  #     case rest do
  #       [] -> Enum.min(Map.keys(new_map), fn -> nil end)
  #       _ -> pq.min
  #     end

  #   {first, new_pq(new_map, new_min)}
  # end

  ################################################

  def expected_addl_cost(w, h) do
    fn {x, y} ->
      # rectangle distance
      w - x + (h - y)
    end
  end

  def next_explore(choices) do
    Enum.min_by(choices, fn {_c, {ev, _v, _p}} -> ev end)
  end

  def adjacent_points(width, height) do
    fn {x, y} ->
      Enum.filter([{x, y - 1}, {x - 1, y}, {x + 1, y}, {x, y + 1}], fn {a, b} ->
        a >= 0 && a <= width && b >= 0 && b <= height
      end)
    end
  end

  def new_choices(point, cost, risks, choices, lowest_costs, addl_f, adj_f) do
    lower_cost_points =
      adj_f.(point)
      |> Enum.map(fn p ->
        cost_so_far = risks[p] + cost
        expected_cost = addl_f.(p) + cost_so_far
        {expected_cost, choice(p, cost_so_far)}
      end)
      |> Enum.filter(fn {_exp, ch} ->
        ch.cost < Map.get(lowest_costs, ch.point)
      end)

    new_cs =
      lower_cost_points
      |> Enum.reduce(choices, fn new, pq ->
        PQ.insert(pq, new)
      end)

    new_points_dict =
      Enum.map(lower_cost_points, fn {_exp, choice} ->
        {choice.point, choice.cost}
      end)
      |> Enum.into(%{})

    new_lowest_costs = Map.merge(lowest_costs, new_points_dict)
    {new_cs, new_lowest_costs}
  end

  def tick(risks, choices, lowest_costs, target, addl_f, adj_f) do
    {{cost, next}, choices} = PQ.pop(choices)

    if next.point == target do
      next
    else
      {upd_choices, upd_costs} =
        new_choices(
          next.point,
          next.cost,
          risks,
          choices,
          lowest_costs,
          addl_f,
          adj_f
        )

      tick(
        risks,
        upd_choices,
        upd_costs,
        target,
        addl_f,
        adj_f
      )
    end
  end

  def find_shortest_path(input) do
    last_row = length(input) - 1
    last_column = length(Enum.at(input, 0)) - 1

    risk_map = produce_input_map(input)

    adjacent_points_f = adjacent_points(last_column, last_row)
    addl_cost_f = expected_addl_cost(last_column, last_row)

    start_choices =
      PQ.new()
      |> PQ.insert({last_row + last_column + 2, choice({0, 0}, 0)})

    lowest_costs = %{}

    tick(
      risk_map,
      start_choices,
      lowest_costs,
      {last_column, last_row},
      addl_cost_f,
      adjacent_points_f
    ).cost
  end

  def part1(input) do
    find_shortest_path(input)
  end

  def extend_horiz(line) do
    List.flatten(for n <- 0..4, do: Enum.map(line, fn p -> rem(p + n, 10) + div(p + n, 10) end))
  end

  def create_5_map(input) do
    input
    |> Enum.map(fn l ->
      extend_horiz(l)
    end)
  end

  def part2(input) do
    new_input =
      create_5_map(input)
      |> Enum.zip()
      |> Enum.map(&Tuple.to_list/1)
      |> create_5_map()
      |> Enum.zip()
      |> Enum.map(&Tuple.to_list/1)

    new_input
    |> find_shortest_path()
  end

  def test_solution do
    test_input = read_input_file("test.txt")
    IO.puts("Answer Part1 = " <> "40")
    IO.inspect(part1(test_input))
    IO.puts("Answer Part2 = " <> "315")
    IO.inspect(part2(test_input))
  end

  def real_solution do
    input = read_input_file("input-8.txt")
    IO.inspect(part1(input))
    IO.inspect(part2(input))
  end

  def main do
    test_solution()
    real_solution()
  end
end
