defmodule Etags.Example.Foo do
  @moduledoc """
  Foo Resource
  """
  use Ash.Resource,
    data_layer: Ash.DataLayer.Ets

  require Etags.Common.Attributes

  code_interface do
    define_for Etags.Example

    define :create, action: :create
    define :list, action: :read
    define :update, action: :update
    define :destroy, action: :destroy
    define :get_by_id, args: [:id], action: :by_id
  end

  actions do
    defaults [:create, :read, :update, :destroy]

    read :by_id do
      argument :id, :string do
        allow_nil? false
      end

      get? true
      filter expr(id == ^arg(:id))
    end
  end

  calculations do
    calculate :etag,
              :string,
              {Etags.Common.Calculations.WeakETag, []} do
      argument :salt, :string do
        allow_nil? false
        constraints allow_empty?: true, trim?: false
      end
    end
  end

  attributes do
    Etags.Common.Attributes.uuid(slug: "foo")

    attribute :title, :string do
      allow_nil? false

      constraints max_length: 20,
                  min_length: 5,
                  trim?: true
    end

    timestamps()
  end
end
