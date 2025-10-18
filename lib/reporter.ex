defmodule Packer.Reporter do
  def run(instance, solution) do
    %{
      out_traffic: out_traffic(instance, solution),
      in_traffic: in_traffic(instance, solution)
    }
  end

  defp out_traffic(%{
    process_links_from: links_from,
    process_links_to: links_to,
    process_message_volume: message_volume
    } = _instance,
    %{"remote_call" => remote_calls, "process_placement"=> placement} = _solution) do

    Enum.zip([remote_calls, links_from, links_to])
    |> Enum.flat_map(fn {remote?, sender, receiver} -> remote? &&
    [%{sender: sender, receiver: receiver,
      sender_node: Enum.at(placement, sender - 1),
      receiver_node: Enum.at(placement, receiver - 1)
    }] || [] end)

  |> Enum.group_by(fn rec -> {rec.sender,rec.sender_node} end)
  |> Enum.map(fn {{sender, n} = _k, receivers} ->
    %{node: n, sender: sender, out_volume: length(receivers) * Enum.at(message_volume, sender - 1)}
    end)
  |> Enum.group_by(fn rec -> rec.node end, fn rec -> Map.take(rec, [:sender, :out_volume]) end)

  end

  defp in_traffic(_instance, %{"node_inbound" => node_inbound} = _solution) do
    node_inbound
    |> Enum.with_index(1)
    |> Map.new()
  end
end
