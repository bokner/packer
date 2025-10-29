defmodule Packer.Checker do
  import Packer.Utils

  require Logger

  @spec run(
          %{
            :process_links_from => any(),
            :process_links_to => any(),
            :topology => any(),
            optional(any()) => any()
          },
          map()
        ) :: boolean()
  def run(instance, solution) do
    check_process_links(instance, solution) and
      check_memory(instance, solution) and
      check_load(instance, solution) and
      check_bandwidth(instance, solution)
  end

  @spec check_process_links(
          %{
            :process_links_from => any(),
            :process_links_to => any(),
            :topology => any(),
            optional(any()) => any()
          },
          map()
        ) :: boolean()
  def check_process_links(
        %{
          process_links_from: links_from,
          process_links_to: links_to,
          topology: topology
        } = _instance,
        %{"process_placement" => placement} = _solution
      ) do

    get_remote_calls(links_from, links_to, placement)
    |> Enum.all?(fn link_id ->
      from = Enum.at(links_from, link_id - 1)
      to = Enum.at(links_to, link_id - 1)
      from_node = Enum.at(placement, from - 1)
      to_node = Enum.at(placement, to - 1)
      ## nodes are the same or connected
      ## remote calls properly identifies
      Enum.at(Enum.at(topology, from_node - 1), to_node - 1) and
        from_node != to_node
    end)
    |> tap(fn valid? -> !valid? && Logger.error("Invalid process link placement") end)
  end

  @spec check_load(
          %{:node_load => any(), :process_load => any(), optional(any()) => any()},
          map()
        ) :: boolean()
  def check_load(
        %{
          process_load: process_load,
          node_load: node_load
        } = _instance,
        %{"process_placement" => placement} = _solution
      ) do
    Enum.all?(
      Enum.zip(node_load, nodes_to_processes_mapping(placement)),
      fn {node_load, processes} ->
        Enum.sum_by(processes, fn p_id -> Enum.at(process_load, p_id - 1) end) <= node_load
      end
    )
    |> tap(fn valid? -> !valid? && Logger.error("Load check failed") end)
  end

  @spec check_memory(
          %{:node_memory => any(), :process_memory => any(), optional(any()) => any()},
          map()
        ) :: boolean()
  def check_memory(
        %{
          process_memory: process_memory,
          node_memory: node_memory
        } = _instance,
        %{"process_placement" => placement} = _solution
      ) do
    processes = nodes_to_processes_mapping(placement)

    Enum.all?(
      Enum.zip(node_memory, processes),
      fn {node_memory, processes} ->
        Enum.sum_by(processes, fn p_id -> Enum.at(process_memory, p_id - 1) end) <= node_memory
      end
    )
    |> tap(fn valid? -> !valid? && Logger.error("Memory check failed") end)
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
         %{
           "process_placement" => placement,
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
      get_remote_calls(links_from, links_to, placement)
      |> MapSet.new(fn link_id -> Enum.at(links, link_id - 1) end)

    caller_volumes =
      process_message_volume
      |> Enum.with_index(1)
      |> Enum.filter(fn {_volume, idx} -> idx in participants end)
      |> Map.new(fn {v, idx} -> {idx, v} end)

    ## Bandwidth limits per node respected
    ## Inbound and outbound bandwidths across the cluster are balanced
    (placement
     |> nodes_to_processes_mapping()
     |> Enum.zip(node_bandwidth)
     |> Enum.all?(fn {processes, node_bandwidth} ->
       callers_on_node = MapSet.intersection(participants, processes)

       node_bandwidth >=
         Enum.sum_by(
           callers_on_node,
           fn caller -> Map.get(caller_volumes, caller) end
         )
     end) and
       Enum.sum(node_outbound) == Enum.sum(node_inbound))
    |> tap(fn valid? -> !valid? && Logger.error("Bandwidth check failed") end)
  end

  def get_remote_calls(links_from, links_to, process_placement) do
    Enum.zip(links_from, links_to)
    |> Enum.with_index(1)
    |> Enum.reduce(MapSet.new(), fn {{from, to}, link_id}, acc ->
      Enum.at(process_placement, from - 1) != Enum.at(process_placement, to - 1) &&
      MapSet.put(acc, link_id) || acc
    end)
    # {_, remote_calls} =
    #   Enum.reduce(flags, {1, MapSet.new()}, fn remote_call?, {idx, acc} ->
    #     {idx + 1, (remote_call? && MapSet.put(acc, idx)) || acc}
    #   end)

    # remote_calls
  end
end
