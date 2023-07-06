defmodule Etags.Common.Attributes do
  alias Etags.Common.Utils.UUID

  defmacro uuid(opts \\ [slug: "id"]) do
    quote do
      attribute :id, :string do
        allow_nil? false
        writable? false
        default(fn -> UUID.generate(unquote(opts[:slug])) end)
        primary_key? true
        generated? false
      end
    end
  end
end
