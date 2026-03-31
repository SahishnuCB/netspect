defmodule NetspectBackendWeb.PageController do
  use NetspectBackendWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
