defmodule Couchdb.Connector.Configuration do
  @moduledoc """
  Provides functions to access the server's configuration.
  """

  alias Couchdb.Connector.UrlHelper
  alias Couchdb.Connector.ResponseHandler, as: Handler

  @doc """
  Returns complete server configuration.
  """
  @spec get(db_properties, String.t, String.t) :: String.t
  def get db_props, admin_name, password do
    db_props
    |> UrlHelper.config_url(admin_name, password)
    |> HTTPoison.get!
    |> Handler.handle_get
  end
end