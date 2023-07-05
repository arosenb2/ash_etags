defmodule Etags.Example do
  use Ash.Api

  resources do
    registry Etags.Example.Registry
  end
end
