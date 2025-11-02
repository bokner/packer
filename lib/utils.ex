defmodule Packer.Utils do
  alias InPlace.{Array, Heap}

  def nodes_to_processes_mapping(process_placement) do
    process_placement
    |> Enum.with_index(1)
    |> Enum.group_by(fn {node, _idx} -> node end, fn {_, idx} -> idx end)
    |> then(fn m ->
      Enum.map(
        1..7,
        fn node -> {node, Map.get(m, node, []) |> MapSet.new()} end
      )
    end)
    |> Enum.sort()
    |> Enum.map(fn {_, processes} -> processes end)
  end

  ## Randomly splits positive number into required number of partitions
  def random_split(n, num_partitions)
      when is_integer(n) and
             is_integer(num_partitions) and
             n > 0 and
             num_partitions > 0 do
    heap = Heap.new(num_partitions * 2)

    last =
      Enum.reduce(1..(num_partitions - 1), n, fn _idx, to_split ->
        num1 = min(to_split - 1, :rand.uniform(to_split))
        num2 = to_split - num1
        Heap.insert(heap, -num1)
        Heap.insert(heap, -num2)
        -Heap.extract_min(heap)
      end)

    [last | Array.to_list(heap.array) |> Enum.take(Heap.size(heap)) |> Enum.map(fn x -> -x end)]
  end

  def random_intervals(n, num_partitions) do
    random_split(n, num_partitions)
    |> then(fn partitions ->
      [first | rest] = partitions

      Enum.reduce(rest, [first], fn partition_size, [h | _] = acc ->
        [h + partition_size | acc]
      end)
      |> Enum.reverse()
    end)
  end

  def partition_index(index, intervals) when is_integer(index) do
    Enum.reduce_while(intervals, 1, fn upper_bound, acc ->
      (index <= upper_bound && {:halt, acc}) ||
        {:cont, acc + 1}
    end)
  end
end
