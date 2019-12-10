defmodule Couchdb.Connector.Request do
  @moduledoc """
  TODO: docs
  """

  @hackey_opts [hackney: [:insecure, timeout: 60000, recv_timeout: 60000]]

  def get(a) do
    HTTPoison.get(a, [{"Accept", "application/json"}], @hackey_opts)
  end

  def put(a, b, c \\ []) do
    HTTPoison.put(a, b, c, @hackey_opts)
  end

  def post(a, b, c \\ []) do
    HTTPoison.post(a, b, c, @hackey_opts)
  end

  def delete(a, b \\ []) do
    HTTPoison.delete(a, b, @hackey_opts)
  end

end
