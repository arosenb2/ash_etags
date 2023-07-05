defmodule EtagsWeb.Controllers.FooController do
  @moduledoc false

  require Logger

  use EtagsWeb, :controller

  alias Etags.Example.Foo
  alias EtagsWeb.Dtos.FooResponse

  @etag_salt "foo"

  def list(conn, _opts) do
    with {:ok, values} <- Foo.list() do
      conn
      |> json(%{
        items: Enum.map(values, &FooResponse.from/1)
      })
    else
      _ ->
        conn
        |> send_resp(:internal_server_error, "")
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, etag} <- fetch_etag(id),
         :ok <- process_etag(conn, etag, "if-none-match") do
      conn
      |> send_resp(:not_modified, "")
    else
      {:error, {:invalid_or_missing_etag, etag}} ->
        with {:ok, value} <- Foo.get_by_id(id) do
          # Artificial delay for processing
          :timer.sleep(1_500)

          conn
          |> put_resp_header("ETag", etag)
          |> put_status(:ok)
          |> json(FooResponse.from(value))
        else
          _ ->
            conn
            |> send_resp(:not_found, "")
        end

      _ ->
        conn
        |> send_resp(:not_found, "")
    end
  end

  def patch(conn, %{"id" => id} = params) do
    with {:ok, resource} <- Foo.get_by_id(id),
         {:ok, etag} <- fetch_etag(id),
         :ok <- process_etag(conn, etag, "if-match"),
         {:ok, changeset} <- validate_patch(resource, params) do
      case Etags.Example.update(changeset) do
        {:ok, result} ->
          {:ok, %Foo{etag: new_etag}} = Etags.Example.load(result, etag: [salt: @etag_salt])

          Logger.debug("New ETag for resource: #{new_etag} (previous: #{etag})")

          conn
          |> put_resp_header("ETag", new_etag)
          |> put_status(:ok)
          |> json(FooResponse.from(result))
      end
    else
      {:error, %Ash.Error.Query.NotFound{}} ->
        conn
        |> send_resp(:not_found, "")

      {:error, {:invalid_or_missing_etag, _}} ->
        conn
        |> send_resp(:precondition_failed, "")

      {:error, {:unprocessable_entity, _}} ->
        conn
        |> send_resp(:unprocessable_entity, "")

      error ->
        IO.inspect(error)

        conn
        |> send_resp(:internal_server_error, "")
    end
  end

  defp validate_patch(%Foo{} = resource, %{"title" => title} = _incoming) do
    changeset =
      resource
      |> Ash.Changeset.new()
      |> Ash.Changeset.change_attribute(:title, title)
      |> Ash.Changeset.for_action(:update)

    case changeset do
      %Ash.Changeset{valid?: true} -> {:ok, changeset}
      _ -> {:error, {:unprocessable_entity, changeset}}
    end
  end

  defp fetch_etag(resource_id) do
    {:ok, %{etag: etag}} =
      Foo.query_to_get_by_id(resource_id)
      |> Ash.Query.select([:id, :updated_at])
      |> Ash.Query.load(etag: [salt: @etag_salt])
      |> Etags.Example.read_one()

    Logger.debug("Fetched ETag for Resource #{resource_id} - #{etag}")

    {:ok, etag}
  end

  defp process_etag(conn, etag, header_name) do
    {etags_to_match, _} =
      get_req_header(conn, header_name)
      |> Enum.flat_map_reduce([], fn value, acc ->
        {Enum.concat(acc, String.split(value, ",")), acc}
      end)

    cond do
      Enum.member?(etags_to_match, etag) ->
        Logger.debug("Validated ETag - #{etag}")
        :ok

      true ->
        Logger.debug(
          "No matching ETags - needle: #{etag}, haystack: [#{Enum.join(etags_to_match, ", ")}]"
        )

        {:error, {:invalid_or_missing_etag, etag}}
    end
  end
end
