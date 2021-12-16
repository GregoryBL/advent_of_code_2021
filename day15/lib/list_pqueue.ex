defmodule PQ do
  defmodule ListPQ do
    defstruct list: [],
              min: nil,
              list_length: 0,
              aux_list: [],
              aux_list_min: nil,
              aux_list_size: 0
  end

  def new() do
    %ListPQ{}
  end

  def remove_min(list) do
    # Should keep second to minimum too
    {b, sm, a, sec_min} =
      Enum.reduce(
        list,
        {[], {nil, nil}, [], nil},
        fn {n_s, n_v}, {before, {score, val}, aft, secondary_min_score} ->
          cond do
            score == nil ->
              {[], {n_s, n_v}, [], nil}

            n_s == score ->
              {before, {score, val}, [{n_s, n_v} | aft], n_s}

            n_s < score ->
              {
                before ++ Enum.reverse([{score, val} | aft]),
                {n_s, n_v},
                [],
                score
              }

            true ->
              {before, {score, val}, [{n_s, n_v} | aft], secondary_min_score}
          end
        end
      )

    {sm, Enum.reverse(a ++ b), sec_min}
  end

  def pop(pq) do
    {sm, rm, new_min} = remove_min(pq.list)

    new_pq = %ListPQ{
      pq
      | list: rm,
        list_length: pq.list_length - 1,
        min: new_min
    }

    if new_pq.list_length < 50 || new_pq.min >= new_pq.aux_list_min do
      {sm, recombine_from_aux_list(new_pq)}
    else
      {sm, new_pq}
    end
  end

  def _insert(pq, {score, val}) do
    %ListPQ{
      pq
      | list: [{score, val} | pq.list],
        min: min(score, pq.min),
        list_length: pq.list_length + 1
    }
  end

  def push_to_aux_list(pq, keep \\ 100) do
    if pq.list_length <= keep do
      pq
    else
      {new_list, new_aux} =
        Enum.sort(pq.list, fn {a, _va}, {b, _vb} ->
          a <= b
        end)
        |> Enum.split(keep)

      aux_list = new_aux ++ pq.aux_list
      [{s, _v} | _rest] = new_aux

      # Min remains the same
      %ListPQ{
        pq
        | list: new_list,
          list_length: keep,
          aux_list: new_aux,
          aux_list_min: min(s, pq.aux_list_min),
          aux_list_size: pq.aux_list_size + pq.list_length - keep
      }
    end
  end

  def recombine_from_aux_list(pq, keep \\ 100) do
    push_to_aux_list(
      %ListPQ{
        pq
        | list: pq.list ++ pq.aux_list,
          list_length: pq.list_length + pq.aux_list_size,
          aux_list: [],
          aux_list_min: nil,
          aux_list_size: 0
      },
      keep
    )
  end

  def insert(pq, {score, val}) do
    new_pq = _insert(pq, {score, val})

    if new_pq.list_length > 200 do
      push_to_aux_list(new_pq)
    else
      new_pq
    end
  end
end
