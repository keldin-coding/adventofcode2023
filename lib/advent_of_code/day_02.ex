defmodule AdventOfCode.Day02 do
  def part1(input) do
    # Setup of statics
    maximums = %{
      red: 12,
      green: 13,
      blue: 14
    }

    exceeds_a_maximum = fn draw ->
      Enum.any?(maximums, fn {color, max} -> draw[color] > max end)
    end

    input
    |> separate_input()
    |> Enum.map(&parse_line(&1))
    |> Enum.reduce(0, fn line_data, acc ->
      if Enum.any?(line_data[:draws], &exceeds_a_maximum.(&1)) do
        acc
      else
        acc + line_data[:id]
      end
    end)
  end

  def part2(input) do
    input
    |> separate_input()
    |> Enum.map(&parse_line(&1))
    |> Enum.map(&required_of_each_color(&1))
    |> Enum.reduce(0, fn required, acc ->
      acc + required[:red] * required[:green] * required[:blue]
    end)
  end

  defp required_of_each_color(line_data) do
    Enum.reduce(line_data[:draws], %{red: 0, green: 0, blue: 0}, fn draw, acc ->
      acc
      |> Map.put(:red, determine_new_required(draw[:red], acc[:red]))
      |> Map.put(:green, determine_new_required(draw[:green], acc[:green]))
      |> Map.put(:blue, determine_new_required(draw[:blue], acc[:blue]))
    end)
  end

  defp determine_new_required(to_check, current) do
    if to_check > 0 and (current == 0 or to_check > current) do
      to_check
    else
      current
    end
  end

  defp separate_input(input) do
    input
    |> String.trim()
    |> String.split("\n")
  end

  defp parse_line("Game " <> rest) do
    result = %{}

    [id, rest] = String.split(rest, ": ")
    result = Map.put(result, :id, String.to_integer(id))

    draws = String.split(rest, ";") |> Enum.map(&parse_draw(&1))

    Map.put(result, :draws, draws)
  end

  defp parse_draw(draw) do
    color_to_regex = %{
      red: ~r/(\d+) red/,
      green: ~r/(\d+) green/,
      blue: ~r/(\d+) blue/
    }

    Enum.reduce(color_to_regex, %{}, fn {color, matcher}, acc ->
      case Regex.run(matcher, draw) do
        nil ->
          Map.put(acc, color, 0)

        [_whole_match, number] ->
          Map.put(acc, color, String.to_integer(number))
      end
    end)
  end
end
