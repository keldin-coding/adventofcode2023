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
    |> Enum.reduce(0, fn line, acc ->
      line_data = parse_line(line)

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
    |> Enum.reduce(0, fn line, acc ->
      line_data = parse_line(line)

      is_new_required = fn to_check, current ->
        to_check > 0 && (current == 0 or to_check > current)
      end

      required =
        Enum.reduce(line_data[:draws], %{red: 0, green: 0, blue: 0}, fn draw, acc ->
          Enum.reduce([:red, :green, :blue], acc, fn color, nested_acc ->
            if(is_new_required.(draw[color], nested_acc[color]),
              do: Map.put(nested_acc, color, draw[color]),
              else: nested_acc
            )
          end)
        end)

      acc + required[:red] * required[:green] * required[:blue]
    end)
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
