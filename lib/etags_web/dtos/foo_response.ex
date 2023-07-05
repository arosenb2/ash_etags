defmodule EtagsWeb.Dtos.FooResponse do
  @moduledoc false

  alias Etags.Example.Foo

  @public_fields [
    :id,
    :title,
    :inserted_at,
    :updated_at
  ]

  @derive {Jason.Encoder, only: @public_fields}

  defstruct @public_fields

  def from(%Foo{} = model) do
    Map.merge(
      %__MODULE__{},
      %{
        id: model.id,
        title: model.title,
        inserted_at: model.inserted_at,
        updated_at: model.inserted_at
      }
    )
  end
end
