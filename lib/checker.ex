defmodule Packer.Checker do
  def run(instance, solution) do
    check_process_links(instance, solution) and
      check_memory(instance, solution) and
      check_load(instance, solution) and
      check_bandwidth(instance, solution)
  end

  def check_process_links(
        %{
          process_links_from: links_from,
          process_links_to: links_to,
          topology: topology
        } = _instance,
        %{"process_placement" => mapping, "remote_calls" => remote_call} = _solution
      ) do
    Enum.all?(Enum.zip([links_from, links_to, remote_call]), fn {from, to, remote_call_flag} ->
      from_node = Enum.at(mapping, from - 1)
      to_node = Enum.at(mapping, to - 1)
      ## nodes are the same or connected
      ## remote calls properly identifies
      (Enum.at(Enum.at(topology, from_node - 1), to_node - 1) and
         remote_call_flag == false) || (remote_call_flag == true and from_node != to_node)
    end)
  end

  def check_load(
        %{
          process_load: process_load,
          node_load: node_load
        } = _instance,
        %{"processes_on_node" => mapping} = _solution
      ) do
    Enum.all?(
      Enum.zip(node_load, mapping),
      fn {node_load, processes} ->
        Enum.sum_by(processes, fn p_id -> Enum.at(process_load, p_id - 1) end) <= node_load
      end
    )
  end

  def check_memory(
        %{
          process_memory: process_memory,
          node_memory: node_memory
        } = _instance,
        %{"processes_on_node" => mapping} = _solution
      ) do
    Enum.all?(
      Enum.zip(node_memory, mapping),
      fn {node_memory, processes} ->
        Enum.sum_by(processes, fn p_id -> Enum.at(process_memory, p_id - 1) end) <= node_memory
      end
    )
  end

  defp check_bandwidth(instance, solution) do
    check_bandwidth(instance, solution, :out) and
      check_bandwidth(instance, solution, :in)
  end

  defp check_bandwidth(
         %{
           process_links_from: links_from,
           process_links_to: links_to,
           node_bandwidth_out: node_bandwidth_out,
           node_bandwidth_in: node_bandwidth_in,
           process_message_volume: process_message_volume
         } = _instance,
         %{"remote_calls" => remote_call_flags, "processes_on_node" => processes_on_node,
            "node_outbound" => node_outbound,
            "node_inbound" => node_inbound
          } =
           _solution,
         direction
       ) do
    {links, node_bandwidth} =
      if direction == :out do
        {links_from, node_bandwidth_out}
      else
        {links_to, node_bandwidth_in}
      end

    participants =
      remote_call_flags
      |> Enum.zip(links)
      |> Enum.flat_map(fn {r_flag, process_id} -> (r_flag == true && [process_id]) || [] end)
      |> MapSet.new()

    caller_volumes =
      process_message_volume
      |> Enum.with_index(1)
      |> Enum.filter(fn {_volume, idx} -> idx in participants end)
      |> Map.new(fn {v, idx} -> {idx, v} end)

    ## Bandwidth limits per node respected
    processes_on_node
    |> Enum.zip(node_bandwidth)
    |> Enum.all?(fn {processes, node_bandwidth} ->
      callers_on_node = MapSet.intersection(participants, processes)

      node_bandwidth >=
        Enum.sum_by(
          callers_on_node,
          fn caller -> Map.get(caller_volumes, caller) end
        )
    end)
    ## Inbound and outbound bandwidths across the cluster are balanced
    and Enum.sum(node_outbound) == Enum.sum(node_inbound)
  end
end
