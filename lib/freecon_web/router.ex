defmodule FreeconWeb.Router do
  use FreeconWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {FreeconWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :protected do
    plug FreeconWeb.VerifyProfessorSession
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", FreeconWeb do
    pipe_through :browser

    live "/", PageLive, :index
    live "/room/round/trade", TradeScreenLive

    resources "/professors", ProfessorController, only: [:new, :create]
    resources "/sessions", SessionController, only: [:create]

    get "/login", SessionController, :new
    get "/logout", SessionController, :delete
  end

  scope "/dashboard/", FreeconWeb do
    pipe_through [:browser, :protected]

    live "/", ProfessorDashboard
    live "/room/:id", RoomLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", FreeconWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/monitoring_dashboard", metrics: FreeconWeb.Telemetry
    end
  end
end
