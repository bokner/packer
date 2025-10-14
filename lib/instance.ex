defmodule Packer.Instance do
  @doc """
    Generates instance of cluster data.
    It's a map with:

    :topology - the adjacency matrix of the topology graph (connections between nodes);
    :process_links - the adjacency list of the link graph (pairs of processes that have to communicate);
    :nodes - map `node => data`;
    :processes - map `process => data`;
  """
  @spec generate(pos_integer(), pos_integer(), Keyword.t()) :: map()
  def generate(num_nodes, num_processes, opts \\ []) do
    opts = Keyword.merge(default_opts(), opts)

    %{
      num_nodes: num_nodes,
      num_processes: num_processes,
      topology: generate_topology(num_nodes, opts),
      process_links: generate_process_links(num_processes, opts),
      nodes: generate_nodes(num_nodes, opts),
      processes: generate_processes(num_processes, opts)
    }
    |> to_params(opts)
    |> tap(fn instance ->
      case Keyword.get(opts, :handler) do
        nil -> instance
        handler_fun -> handler_fun.(instance, opts)
      end
    end)
  end

  # Generates adjacency matrix for topology graph
  defp generate_topology(num_nodes, opts) do
    generate_graph(
      num_nodes,
      false,
      :adjacency_matrix,
      Keyword.get(opts, :nodes_connected_probability)
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

  @spec generate_graph(pos_integer(), boolean(), :adjacency_list | :adjacency_matrix, float()) ::
          any()
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

    %{from: from, to: to}
  end

  defp generate_adjacency_matrix(num_vertices, symmetric?, edge_probability) do
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
            random_bool(edge_probability)
        end

      Map.put(acc, n, value)
    end)
    |> Enum.sort_by(fn {vertex_num, _val} -> vertex_num end)
    |> Enum.map(fn {_vertex_num, val} -> val end)
    |> Enum.chunk_every(num_vertices)
  end

  defp generate_nodes(num_nodes, opts) do
    Enum.map(1..num_nodes, fn n ->
      %{
        node_id: n,
        memory: random_value(opts[:node_memory_range]),
        cpu: random_value(opts[:node_cpu_range]),
        bandwidth_out: random_value(opts[:node_bandwidth_out_range]),
        bandwidth_in: random_value(opts[:node_bandwidth_in_range])
      }
    end)
  end

  def generate_processes(num_processes, opts) do
    Enum.map(1..num_processes, fn n ->
      %{
        process_id: n,
        memory: random_value(opts[:process_memory_range]),
        load: random_value(opts[:process_cpu_load_range]),
        message_volume: random_value(opts[:process_message_volume_range]),
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
      node_memory_range: 512..2048,
      node_cpu_range: 500..1000,
      node_bandwidth_out_range: 100..5000,
      node_bandwidth_in_range: 100..5000,
      process_memory_range: 10..512,
      process_cpu_load_range: 100..600,
      process_message_volume_range: 50..200,
      nodes_connected_probability: 0.9,
      processes_linked_probability: 0.1,
      handler: &to_dzn/2
    ]
  end

  defp to_params(%{num_nodes: num_nodes, num_processes: num_processes} = instance, _opts) do
    {process_memory, process_load, process_msg_volume} =
      Enum.reduce(instance[:processes], {[], [], []}, fn %{memory: memory, load: load, message_volume: message_volume},
                                                     {m_acc, l_acc, v_acc} ->
        {[memory | m_acc], [load | l_acc], [message_volume | v_acc]}
      end)

    {node_memory, node_cpu, bandwidth_out, bandwidth_in} =
      Enum.reduce(instance[:nodes], {[], [], [], []},
      fn %{memory: memory, cpu: cpu, bandwidth_out: b_out, bandwidth_in: b_in}, {m_acc, l_acc, b_out_acc, b_in_acc} ->
        {[memory | m_acc], [cpu | l_acc], [b_out | b_out_acc], [b_in | b_in_acc]}
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
      process_message_volume: process_msg_volume,
      node_memory: Enum.reverse(node_memory),
      node_cpu: node_cpu,
      node_bandwidth_out: bandwidth_out,
      node_bandwidth_in: bandwidth_in
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
