defmodule Packer.Instance do
  @doc """
    Generates instance of cluster data.
    It's a map with:

    :topology - the adjacency matrix of the topology graph (connections between nodes);
    :process_links - the adjacency list of the link graph (pairs of processes that have to communicate);
    :nodes - map `node => data`;
    :processes - map `process => data`;
  """
  import Packer.Utils

  @spec generate(pos_integer(), pos_integer(), Keyword.t()) :: map()
  def generate(num_nodes, num_processes, opts \\ []) do
    opts =
      default_opts()
      |> Keyword.merge(opts)
      |> Keyword.put(
        :node_split,
        random_split(num_processes, num_nodes)
        |> then(fn partitions ->
          [first | rest] = partitions

          Enum.reduce(rest, [first], fn partition_size, [h | _] = acc ->
            [h + partition_size | acc]
          end)
          |> Enum.reverse()
        end)
      )

    processes = generate_processes(num_processes, opts)
    process_links = generate_process_links(num_processes, opts)
    topology = generate_topology(num_nodes, process_links, opts)
    nodes = generate_nodes(processes, process_links, opts)

    %{
      num_nodes: num_nodes,
      num_processes: num_processes,
      topology: topology,
      process_links: process_links,
      nodes: nodes,
      processes: processes
    }
    |> to_params(opts)
    |> tap(fn instance ->
      case Keyword.get(opts, :handler) do
        nil -> instance
        handler_fun -> handler_fun.(instance, opts)
      end
    end)
  end

  def generate_processes(num_processes, opts) do
    Enum.map(1..num_processes, fn n ->
      %{
        id: n,
        memory: random_value(opts[:process_memory_range]),
        load: random_value(opts[:process_load_range]),
        message_volume: random_value(opts[:process_message_volume_range])
      }
    end)
  end

  # # Generates adjacency matrix for topology graph
  defp generate_topology(num_nodes, process_links, opts) do
    connected_by_processes =
      Enum.reduce(Enum.zip(process_links.from, process_links.to), MapSet.new(), fn {from_process,
                                                                                    to_process},
                                                                                   acc ->
        from_node = process_home(from_process, opts)
        to_node = process_home(to_process, opts)

        if from_node != to_node do
          MapSet.put(acc, {from_node, to_node})
        else
          acc
        end
      end)

    ## two nodes being connected
    generate_graph(
      num_nodes,
      false,
      :adjacency_matrix,
      fn node1, node2 ->
        if {node1, node2} in connected_by_processes do
          1
        else
          Keyword.get(opts, :nodes_connected_probability)
        end
      end
    )
  end

  defp generate_process_links(num_processes, opts) do
    generate_graph(
      num_processes,
      false,
      :adjacency_list,
      Keyword.get(opts, :processes_linked_probability)
    )
  end

  # @spec generate_graph(pos_integer(), boolean(), :adjacency_list | :adjacency_matrix, float()) ::
  #         any()
  defp generate_graph(num_vertices, directed?, :adjacency_matrix, edge_probability) do
    generate_adjacency_matrix(num_vertices, !directed?, edge_probability)
  end

  defp generate_graph(num_vertices, directed?, :adjacency_list, edge_probability) do
    generate_adjacency_list(num_vertices, directed?, edge_probability)
  end

  defp generate_adjacency_list(num_vertices, symmetric?, edge_probability) do
    {from, to} =
      for i <- 1..(num_vertices - 1), j <- (i + 1)..num_vertices, reduce: [] do
        acc ->
          (random_bool(edge_probability) &&
             ((symmetric? && [{i, j}, {j, i} | acc]) || [{i, j} | acc])) || acc
      end
      |> Enum.unzip()

    %{from: Enum.reverse(from), to: Enum.reverse(to)}
  end

  defp generate_adjacency_matrix(num_vertices, symmetric?, edge_probability_fun) do
    Enum.reduce(1..(num_vertices * num_vertices), Map.new(), fn n, acc ->
      row = div(n - 1, num_vertices) + 1
      col = rem(n - 1, num_vertices) + 1

      value =
        cond do
          # diagonal
          col == row ->
            true

          # lower part, copy from upper, if symmetric
          symmetric? && col < row ->
            Map.get(acc, (col - 1) * num_vertices + row)

          true ->
            random_bool(edge_probability_fun.(row, col))
        end

      Map.put(acc, n, value)
    end)
    |> Enum.sort_by(fn {vertex_num, _val} -> vertex_num end)
    |> Enum.map(fn {_vertex_num, val} -> val end)
    |> Enum.chunk_every(num_vertices)
  end

  defp process_home(process_id, opts) do
    intervals = Keyword.get(opts, :node_split)
    ## Find the node the process is placed to
    partition_index(process_id, intervals)
  end

  def generate_nodes(processes, process_links, opts) do
    link_tuples = Enum.zip(process_links.from, process_links.to)

    link_out_map =
      Enum.group_by(
        link_tuples,
        fn {from, _to} -> from end,
        fn {_from, to} -> to end
      )

    link_in_map =
      Enum.group_by(
        link_tuples,
        fn {_from, to} -> to end,
        fn {from, _to} -> from end
      )

    message_volumes = Map.new(processes, fn p -> {p.id, p.message_volume} end)

    process_id_intervals = Keyword.get(opts, :node_split)

    Enum.group_by(processes, fn p -> partition_index(p.id, process_id_intervals) end)
    |> Enum.map(fn {node_id, node_processes} ->
      total_process_memory = Enum.sum_by(node_processes, fn p -> p.memory end)
      total_process_load = Enum.sum_by(node_processes, fn p -> p.load end)

      total_process_traffic_out =
        Enum.sum_by(node_processes, fn p ->
          length(Map.get(link_out_map, p.id, [])) * Map.get(message_volumes, p.id)
        end)

      total_process_traffic_in =
        Enum.sum_by(node_processes, fn p ->
          senders = Map.get(link_in_map, p.id, [])
          Enum.sum_by(senders, fn p_id -> Map.get(message_volumes, p_id) end)
        end)

      num_processes = length(node_processes)

      %{
        node_id: node_id,
        memory: total_process_memory + random_value(opts[:node_memory_slack]) * num_processes,
        load: total_process_load + random_value(opts[:node_load_slack]) * num_processes,
        bandwidth_out: total_process_traffic_out + random_value(opts[:node_bandwidth_out_slack]),
        bandwidth_in: total_process_traffic_in + random_value(opts[:node_bandwidth_in_slack])
      }
    end)
  end

  defp random_bool(probability) do
    :rand.uniform_real() < probability
  end

  defp random_value(values) do
    Enum.take_random(values, 1) |> hd
  end

  defp default_opts() do
    [
      node_memory_slack: 50..200,
      node_load_slack: 50..200,
      node_bandwidth_out_slack: 500..1000,
      node_bandwidth_in_slack: 500..1000,
      process_memory_range: 128..2048,
      process_load_range: 1000..5000,
      process_message_volume_range: 500..1000,
      nodes_connected_probability: 0.9,
      processes_linked_probability: 0.1,
      handler: &to_dzn/2
    ]
  end

  defp to_params(%{num_nodes: num_nodes, num_processes: num_processes} = instance, _opts) do
    {process_memory, process_load, process_msg_volume} =
      Enum.reduce(instance[:processes], {[], [], []}, fn %{
                                                           memory: memory,
                                                           load: load,
                                                           message_volume: message_volume
                                                         },
                                                         {m_acc, l_acc, v_acc} ->
        {[memory | m_acc], [load | l_acc], [message_volume | v_acc]}
      end)

    {node_memory, node_load, bandwidth_out, bandwidth_in} =
      Enum.reduce(instance[:nodes], {[], [], [], []}, fn %{
                                                           memory: memory,
                                                           load: load,
                                                           bandwidth_out: b_out,
                                                           bandwidth_in: b_in
                                                         },
                                                         {m_acc, l_acc, b_out_acc, b_in_acc} ->
        {[memory | m_acc], [load | l_acc], [b_out | b_out_acc], [b_in | b_in_acc]}
      end)

    process_links_from = get_in(instance, [:process_links, :from])
    process_links_to = get_in(instance, [:process_links, :to])
    num_process_links = length(process_links_from)

    %{
      num_nodes: num_nodes,
      num_processes: num_processes,
      num_process_links: num_process_links,
      topology: Map.get(instance, :topology),
      process_memory: Enum.reverse(process_memory),
      process_load: Enum.reverse(process_load),
      process_message_volume: Enum.reverse(process_msg_volume),
      node_memory: Enum.reverse(node_memory),
      node_load: Enum.reverse(node_load),
      node_bandwidth_out: Enum.reverse(bandwidth_out),
      node_bandwidth_in: Enum.reverse(bandwidth_in)
    }
    |> then(fn instance ->
      ## Temporary. There is a bug in solverl
      ## that generates `array0` dzn in case array has no elements.
      if num_process_links > 0 do
        instance
        |> Map.put(:process_links_from, process_links_from)
        |> Map.put(:process_links_to, process_links_to)
      else
        instance
      end
    end)
  end

  defp to_dzn(%{num_nodes: num_nodes, num_processes: num_processes} = data, _opts) do
    data
    |> MinizincData.to_dzn()
    |> then(fn dzn ->
      File.write("minizinc/instances/n#{num_nodes}_p#{num_processes}.dzn", dzn)
    end)
  end
end
