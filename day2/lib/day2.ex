defmodule Day2 do
  @moduledoc """
  Documentation for `Day2`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Day2.hello()
      :world

  """
  def read_input_file do
    file_contents = File.read!("input-2.txt")
    lines = String.split(file_contents, "\n")
    lines = List.delete_at(lines, 1000)
    Enum.map(lines, fn l ->
      [direction | tail] = String.split(l, " ")
      [amount | _ ] = tail
      {direction, String.to_integer(amount)}
    end)
  end

  def execute_command(direction, current) do
    {current_x, current_y} = current
    case direction do
      {"forward", n} -> put_elem(current, 0, current_x + n)
      {"down", n} -> put_elem(current, 1, current_y + n)
      {"up", n} -> put_elem(current, 1, current_y - n)
    end
  end

  def execute_command2(direction, current) do
    {current_x, current_y, aim} = current
    case direction do
      {"forward", n} -> {current_x + n, current_y + (n * aim), aim}
      {"down", n} -> {current_x, current_y, aim + n}
      {"up", n} -> {current_x, current_y, aim - n}
    end
  end


end
