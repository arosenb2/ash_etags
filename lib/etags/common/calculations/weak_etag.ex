defmodule Etags.Common.Calculations.WeakETag do
  use Ash.Calculation

  @impl true
  def init(opts) do
    if length(opts) === 0 do
      {:ok, opts}
    else
      {:error, "Unexpected opts provided"}
    end
  end

  @impl true
  def load(_query, _opts, _context) do
    []
  end

  @impl true
  def calculate(records, opts, _context) do
    Enum.map(records, fn record ->
      Map.get(record, :updated_at)
      |> calculate_weak_etag!(opts[:salt])
      |> format!()
    end)
  end

  defp calculate_weak_etag!(nil, _salt) do
    raise "Unable to calculate ETag"
  end

  defp calculate_weak_etag!(datetime_timestamp, salt) do
    datetime_timestamp
    |> DateTime.to_unix(:millisecond)
    |> (fn v -> "#{salt}_#{v}" end).()
    |> :erlang.phash2()
    |> Integer.to_string(16)
  end

  defp format!(etag) do
    "W/\"" <> etag <> "\""
  end
end
