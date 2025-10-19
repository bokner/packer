defmodule Packer.Reporter do
  def run(instance, %{"processes_on_node" => processes} = solution) do
    %{node_statistics:
    processes
    |> Enum.with_index(1)
    |> Enum.reduce(Map.new(),
      fn {processes, node_idx}, acc ->
        if MapSet.size(processes) > 0 do
          Map.put(acc, node_idx, get_node_data(node_idx, instance, solution))
        else
          acc
        end
      end),
      topology: instance.topology,
      process_communication: Enum.zip(instance.process_links_from, instance.process_links_to),
      process_demand: Map.take(instance, [:process_memory, :process_load, :process_message_volume])
    }
  end

  defp get_node_data(node_idx,
    %{
      node_bandwidth_in: bandwidth_in,
      node_bandwidth_out: bandwidth_out,
      node_memory: memory,
      process_memory: process_memory,
      node_load: load,
      process_load: process_load
    } = instance,

    %{
      "node_inbound" => traffic_in,
      "node_outbound" => traffic_out,
      "processes_on_node" => processes,
      "remote_calls" => remote_calls
    } = _solution) do
    idx = node_idx - 1
     node_processes = Enum.at(processes, idx)

    %{
      traffic_in: Enum.at(traffic_in, idx),
      traffic_out: Enum.at(traffic_out, idx),
      bandwidth_in: Enum.at(bandwidth_in, idx),
      bandwidth_out: Enum.at(bandwidth_out, idx),
      processes: node_processes,
      memory_used: Enum.sum_by(node_processes, fn p_id -> Enum.at(process_memory, p_id - 1) end),
      load_used: Enum.sum_by(node_processes, fn p_id -> Enum.at(process_load, p_id - 1) end),
      memory_available: Enum.at(memory, idx),
      load_available: Enum.at(load, idx)
    }
    |> Map.merge(get_calls(instance, node_processes, remote_calls))

  end

  defp get_calls(%{process_links_to: links_to, process_links_from: links_from} = _instance, node_processes, remote_calls) do
    # `remote_calls` is an array of boolean().
    # remote_calls[i] = true <-> link[i] is an internode link
    # process_links_from[i] ==> process_links_to[i]
    {calls_out_count, calls_in_count} = Enum.zip([remote_calls, links_to, links_from])
    |> Enum.reduce({0, 0},
      fn {false, _, _}, acc -> acc
         {true, from_process, to_process}, {out_count, in_count} ->
            {
              from_process in node_processes && out_count + 1 || out_count,
              to_process in node_processes && in_count + 1 || in_count
            }

      end)

    %{
      calls_out_count: calls_out_count,
      calls_in_count: calls_in_count
    }
  end

  def markdown_report(instance, solution) do
    report = run(instance, solution)

    _node_report =
    ~s"""
    ## Cluster description (nodes: #{instance.num_nodes}, processes: #{instance.num_processes} )

- ### Capacities per node

|node id| memory | load | out-bandwidth | in-bandwidth
|----| ---    | ---  | ------------- | ------------
#{node_capacities_markdown(report)}

- ### Demand per process

|process id| memory|load|message volume|
|-------| ------|----|--------------
#{demand_per_process_markdown(report)}

- ### Cluster topology

| | #{node_list_markdown(report)} |
#{topology_markdown(report)}

- ### Interprocess requirements

    #{required_calls_markdown(report)}

## Feasible mapping

|node id| processes | memory used/avail. | load used/avail.| out-bandwidth used/avail.| in-bandwidth used/avail.
|----| --- | ----   | ---  | ------------- | ------------
#{feasible_mapping_markdown(report)}

    """
  end

defp node_capacities_markdown(%{node_statistics: statistics} = _report) do
  Enum.reduce(statistics, "", fn {node_id,
    %{
      memory_available: memory,
      load_available: load,
      bandwidth_in: bandwidth_in,
      bandwidth_out: bandwidth_out
    } = _node_data}, acc ->
    acc <> "|  #{node_id}| #{memory} | #{load} | #{bandwidth_in} | #{bandwidth_out} \n"
  end)
end

defp demand_per_process_markdown(%{process_demand: demand} = _report) do
  Enum.zip([demand.process_load, demand.process_memory, demand.process_message_volume])
  |> Enum.with_index(1)
  |> Enum.reduce("", fn {{load, memory, message_volume}, process_id}, acc ->
    acc <> "| #{process_id} | #{memory} | #{load} | #{message_volume} \n"
  end)
end

defp required_calls_markdown(%{process_communication: links} = _report) do
  Enum.reduce(links, "", fn {from, to}, acc -> acc <> "\t- *process#{from}* -> *process#{to}*\n" end)
end

defp feasible_mapping_markdown(%{node_statistics: statistics} = _report) do
  Enum.reduce(statistics, "", fn {node_id,
    %{
      processes: processes,
      load_used: load,
      memory_used: memory,
      traffic_in: traffic_in,
      traffic_out: traffic_out,
      memory_available: memory_available,
      load_available: load_available,
      bandwidth_in: bandwidth_in,
      bandwidth_out: bandwidth_out

    } = _node_data}, acc ->
    acc <> "|  #{node_id}| {#{Enum.join(processes, ",")}} | #{memory}/#{memory_available} | #{load}/#{load_available} | #{traffic_out}/#{bandwidth_out} | #{traffic_in}/#{bandwidth_in} \n"
  end)
end

defp node_list_markdown(%{topology: topology} = _report) do
  Enum.map_join(1..length(topology), " | ", fn id -> "Node #{id}" end)
  <> "\n" <> String.duplicate("|--", length(topology) + 1)
end

defp topology_markdown(%{topology: topology} = _report) do
  for i <- 1..length(topology), reduce: "" do
    acc ->
      line = for j <- 1..length(topology), reduce: "| Node #{i}" do
        line_acc ->
          line_acc <> "| " <> if i == j do
            "."
          else
            Enum.at(topology, i - 1) |> Enum.at(j - 1) && "\u2713" || "\u2717"
          end
      end

      acc <> line <> "\n"
  end
end

end
