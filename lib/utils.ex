defmodule Packer.Utils do
  ## `process_placement[id] = node` <-> process with this id resides on the node
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
end
