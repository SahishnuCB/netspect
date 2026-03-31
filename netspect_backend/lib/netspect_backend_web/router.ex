defmodule NetspectBackendWeb.Router do
  use NetspectBackendWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {NetspectBackendWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", NetspectBackendWeb do
    pipe_through :browser

    live "/", DashboardLive
  end

  scope "/api", NetspectBackendWeb do
    pipe_through :api

    post "/packet", PacketController, :create
    get "/health", HealthController, :index
  end
end
