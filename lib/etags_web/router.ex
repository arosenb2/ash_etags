defmodule EtagsWeb.Router do
  use EtagsWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/v1", EtagsWeb.Controllers do
    pipe_through :api

    get "/foo", FooController, :list
    get "/foo/:id", FooController, :show
    patch "/foo/:id", FooController, :patch
  end
end
