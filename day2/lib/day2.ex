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
    File.read!("input-2.txt")
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn l ->
      [direction, amount] = String.split(l, " ")
      {direction, String.to_integer(amount)}
    end)
  end

  def execute_command(direction, current) do
    {current_x, current_y} = current

    case direction do
      {"forward", n} -> {current_x + n, current_y}
      {"down", n} -> {current_x, current_y + n}
      {"up", n} -> {current_x, current_y - n}
    end
  end

  def execute_command2(direction, current) do
    {current_x, current_y, aim} = current

    case direction do
      {"forward", n} -> {current_x + n, current_y + n * aim, aim}
      {"down", n} -> {current_x, current_y, aim + n}
      {"up", n} -> {current_x, current_y, aim - n}
    end
  end

  def main do
    dirs = read_input_file()
    {x, y} = dirs |> Enum.reduce({0, 0}, &execute_command/2)
    IO.puts(x * y)
    {x2, y2, _} = dirs |> Enum.reduce({0, 0, 0}, &execute_command2/2)
    IO.puts(x2 * y2)
  end
end
