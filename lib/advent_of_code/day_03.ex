defmodule AdventOfCode.Day03 do
  @numbers ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

  defmodule Schematic do
    @numbers ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
    defstruct [:grid, :row_count, :col_count]

    def at(%Schematic{grid: grid}, point) when is_tuple(point) and tuple_size(point) == 2 do
      Map.get(grid, point, nil)
    end

    def touches_symbol?(%Schematic{} = schematic, col_range, row) do
      left_column = for r <- (row - 1)..(row + 1), do: {col_range.first - 1, r}
      right_column = for r <- (row - 1)..(row + 1), do: {col_range.last + 1, r}

      top_row = for c <- (col_range.first - 1)..(col_range.last + 1), do: {c, row - 1}
      bottom_row = for c <- (col_range.first - 1)..(col_range.last + 1), do: {c, row + 1}

      all_points = left_column ++ right_column ++ top_row ++ bottom_row

      Enum.uniq(all_points)
      |> Enum.any?(fn i ->
        case at(schematic, i) do
          "." ->
            false

          num when num in @numbers ->
            false

          nil ->
            false

          _ ->
            true
        end
      end)
    end

    def points_on_all_sides(col_range, row) do
      left_column = for r <- (row - 1)..(row + 1), do: {col_range.first - 1, r}
      right_column = for r <- (row - 1)..(row + 1), do: {col_range.last + 1, r}

      top_row = for c <- (col_range.first - 1)..(col_range.last + 1), do: {c, row - 1}
      bottom_row = for c <- (col_range.first - 1)..(col_range.last + 1), do: {c, row + 1}

      all_points = left_column ++ right_column ++ top_row ++ bottom_row

      Enum.uniq(all_points)
    end
  end

  def part1(input) when is_binary(input) do
    schematic = parse_input(input)

    schematic
    |> numbers_at_ranges()
    |> Enum.reduce(0, fn {value, {col_range, row}}, acc ->
      if Schematic.touches_symbol?(schematic, col_range, row) do
        acc + value
      else
        acc
      end
    end)
  end

  def part2(input) when is_binary(input) do
    schematic = parse_input(input)

    number_locations = numbers_at_ranges(schematic)

    gear_strengths =
      for y <- 1..schematic.row_count, x <- 1..schematic.col_count do
        # Is a gear
        if Schematic.at(schematic, {x, y}) == "*" do
          adjacent_points = Schematic.points_on_all_sides(x..x, y)

          touching =
            Enum.filter(number_locations, fn {_value, {x_range, row}} ->
              Enum.any?(adjacent_points, fn {adjacent_to_gear_x, adjacent_to_gear_y} ->
                row == adjacent_to_gear_y and adjacent_to_gear_x in x_range
              end)
            end)

          if length(touching) == 2 do
            [{first, _}, {second, _}] = touching

            first * second
          end
        end
      end

    gear_strengths
    |> Enum.filter(&(!is_nil(&1)))
    |> Enum.sum()
  end

  @doc """
  Returns a map of:
    row_count: how many rows
    line_length: how wide each row is
    \d: each numbered row
  """
  def parse_input(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.reduce(%Schematic{row_count: 0, col_count: 0, grid: %{}}, fn line,
                                                                         %Schematic{
                                                                           row_count: row_count,
                                                                           grid: grid
                                                                         } = acc ->
      current_row = row_count + 1

      acc
      |> Map.put(:row_count, current_row)
      |> Map.put(:grid, Map.merge(grid, parse_line(String.graphemes(line), current_row)))
      |> Map.put(:col_count, String.length(line))
    end)
  end

  defp parse_line(line, row), do: parse_line(line, row, 1, %{})

  defp parse_line([char | rest], row, column, line_data) do
    parse_line(rest, row, column + 1, Map.put(line_data, {column, row}, char))
  end

  defp parse_line([], _, _, line_data), do: line_data

  defp numbers_at_ranges(schematic) do
    numbers_at_ranges =
      Enum.reduce(1..schematic.row_count, %{current: "", found: []}, fn y, grid_data ->
        row_data =
          Enum.reduce(1..schematic.col_count, %{current: "", found: []}, fn x,
                                                                            %{
                                                                              current:
                                                                                inner_current,
                                                                              found: inner_found
                                                                            } = acc ->
            case Schematic.at(schematic, {x, y}) do
              num when num in @numbers ->
                Map.put(acc, :current, "#{inner_current}#{num}")

              nil ->
                raise "Some assumption has gone terribly, point #{x}, #{y} had nothing"

              _ ->
                inner_current = acc[:current]
                acc = Map.put(acc, :current, "")

                if inner_current == "" do
                  acc
                else
                  Map.put(
                    acc,
                    :found,
                    [
                      {
                        String.to_integer(inner_current),
                        {Range.new(x - String.length(inner_current), x - 1), y}
                      }
                      | inner_found
                    ]
                  )
                end
            end
          end)

        row_data =
          if row_data[:current] == "" do
            row_data
          else
            str = row_data[:current]

            Map.put(row_data, :found, [
              {String.to_integer(str),
               {Range.new(schematic.col_count - String.length(str) + 1, schematic.col_count), y}}
              | row_data[:found]
            ])
          end

        grid_data
        |> Map.put(
          :found,
          for f <- Enum.reverse(row_data[:found]), reduce: grid_data[:found] do
            acc ->
              [f | acc]
          end
        )
      end)

    Enum.reverse(numbers_at_ranges[:found])
  end
end
