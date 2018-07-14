defmodule Couchdb.Connector.UrlHelper do

  @default_db_properties %{user: nil, password: nil}

  @moduledoc """
  Provides URL helper functions that compose URLs based on given database
  properties and additional parameters, such as document IDs, usernames, etc.

  Most of the time, these functions will be used internally. There should
  rarely be a need to access these from within your application.
  """

  alias Couchdb.Connector.Types

  @doc """
  Produces the URL to the server given in db_props.
  """
  @spec database_server_url(Types.db_properties) :: String.t
  def database_server_url db_props do
    @default_db_properties |> Map.merge(db_props) |> do_database_server_url
  end

  defp do_database_server_url db_props = %{user: nil, username: nil} do
    "#{db_props[:protocol]}://#{db_props[:hostname]}:#{db_props[:port]}"
  end

  defp do_database_server_url db_props do
    "#{db_props[:protocol]}://#{db_props[:user] || db_props[:username]}:#{db_props[:password]}@#{db_props[:hostname]}:#{db_props[:port]}"
  end

  @doc """
  Produces the URL to a specific database hosted on the given server.
  """
  @spec database_url(Types.db_properties) :: String.t
  def database_url db_props do
    "#{database_server_url(db_props)}/#{db_props[:database]}"
  end

  @doc """
  Produces the URL to a specific document contained in given database.
  """
  @spec document_url(Types.db_properties, String.t) :: String.t
  def document_url db_props, doc_id do
    "#{database_server_url(db_props)}/#{db_props[:database]}/#{doc_id}"
  end

  @doc """
  Produces the URL to a specific document attachment contained in given database.
  """
  @spec attachment_url(Types.db_properties, String.t, String.t) :: String.t
  def attachment_url db_props, doc_id, att_name do
    "#{database_server_url(db_props)}/#{db_props[:database]}/#{doc_id}/#{att_name}"
  end

  @doc """
  Produces an URL that can be used to retrieve the given number of UUIDs from
  CouchDB. This endpoint does not require authentication.
  """
  @spec fetch_uuid_url(Types.db_properties, non_neg_integer) :: String.t
  def fetch_uuid_url db_props, count \\ 1 do
    "#{database_server_url(db_props)}/_uuids?count=#{count}"
  end

  @doc """
  Produces the URL to a specific design document.
  """
  @spec design_url(Types.db_properties, String.t) :: String.t
  def design_url db_props, design do
    "#{database_server_url(db_props)}/#{db_props[:database]}/_design/#{design}"
  end

  @doc """
  Produces the URL to a specific view from a given design document.
  """
  @spec view_url(Types.db_properties, String.t, String.t) :: String.t
  def view_url db_props, design, view do
    "#{design_url(db_props, design)}/_view/#{view}"
  end

  @doc """
  TODO: write!
  """
  @spec view_url(Types.db_properties, String.t, String.t, map) :: String.t
  def view_url db_props, design, view, query do
    query_str =
      if map_size(query) > 0 do
        "?#{encode_query(query)}"
      else
        ""
      end
    "#{view_url(db_props, design, view)}#{query_str}"
  end

  @doc """
  TODO: write!
  """
  @spec find_url(Types.db_properties) :: String.t
  def find_url db_props do
    "#{database_server_url(db_props)}/#{db_props[:database]}/_find"
  end

  @doc """
  TODO: write!
  """
  @spec index_url(Types.db_properties) :: String.t
  def index_url db_props do
    "#{database_server_url(db_props)}/#{db_props[:database]}/_index"
  end

  @doc """
  Produces the URL to query a view for a specific integer key, using the
  provided staleness setting (either :ok or :update_after).
  """
  @spec query_path(String.t, String.t, atom) :: String.t
  def query_path(view_base_url, key, stale) when is_integer(key) do
    "#{view_base_url}?key=#{URI.encode_www_form(Integer.to_string(key))}&stale=#{Atom.to_string(stale)}"
  end

  @doc """
  Produces the URL to query a view for a specific key, using the provided staleness setting (either :ok or :update_after).
  """
  @spec query_path(String.t, String.t, atom) :: String.t
  def query_path(view_base_url, key, stale) do
    "#{view_base_url}?key=\"#{URI.encode_www_form(key)}\"&stale=#{Atom.to_string(stale)}"
  end

  @doc """
  Produces the URL to a specific user.
  """
  @spec user_url(Types.db_properties, String.t) :: String.t
  def user_url db_props, username do
    "#{database_server_url(db_props)}/_users/org.couchdb.user:#{username}"
  end

  @doc """
  Produces the URL to a specific admin.
  """
  @spec admin_url(Types.db_properties, String.t) :: String.t
  def admin_url db_props, username do
    "#{database_server_url(db_props)}/_config/admins/#{username}"
  end

  @doc """
  Produces the URL to a specific admin, including basic auth params.
  """
  @spec admin_url(Types.db_properties, String.t, String.t) :: String.t
  def admin_url db_props, admin_name, password do
    admin_url(Map.merge(db_props, %{user: admin_name, password: password}), admin_name)
  end

  @doc """
  Produces the URL to the database's security object. Requires admin
  credentials.
  """
  @spec security_url(Types.db_properties) :: String.t
  def security_url db_props do
    "#{database_url(db_props)}/_security"
  end

  @doc """
  TODO: write!
  """
  @spec encode_query(map) :: String.t
  def encode_query(map) do
    Enum.map_join(map, "&", &encode_kv_pair/1)
  end

  defp encode_kv_pair({key, _}) when is_list(key) do
    raise ArgumentError, "encode_query/1 keys cannot be lists, got: #{inspect(key)}"
  end
  defp encode_kv_pair({_, value}) when is_list(value) do
    raise ArgumentError, "encode_query/1 values cannot be lists, got: #{inspect(value)}"
  end
  defp encode_kv_pair({key, value}) do
    URI.encode_www_form(Kernel.to_string(key)) <> "=" <> encode_value(value)
  end
  defp encode_value(value) when is_binary(value) do
    "\"#{URI.encode_www_form(Kernel.to_string(value))}\""
  end
  defp encode_value(value) do
    URI.encode_www_form(Kernel.to_string(value))
  end

end
