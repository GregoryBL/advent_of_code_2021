defmodule Day1 do
  @moduledoc """
  Documentation for `Day1`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Day1.hello()
      :world

  """
  def read_input_file do
    file_contents = File.read!("input.txt")
    lines = String.split(file_contents, "\n")
    items = Enum.map(lines, fn l ->
      if l == "" do
        0
      else
        String.to_integer(l)
      end
    end)
    if List.last(items) == 0 do
      List.delete_at(items, 2000)
    else
      items
    end
  end

  def number_increased(list) do
    list2 = [Enum.at(list, 1) | list]
    Enum.zip_reduce([list, list2], 0, fn [first, second], acc ->
      case first > second do
        true -> acc + 1
        false -> acc
      end
    end)
  end

  def sum_by_3(list) do
    Enum.map(Enum.chunk_every(list, 3, 1, :discard), fn t ->
      Enum.reduce(t, 0, fn elem, acc -> acc + elem end)
    end)
  end
end
