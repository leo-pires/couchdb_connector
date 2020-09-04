defmodule Couchdb.Connector.ResponseHandler do
  @moduledoc """
  Response handler provides functions that handle responses for the happy
  paths and error cases.
  """

  @spec handle_get(%{atom => Integer, atom => String.t}) :: {:ok, String.t} | {:error, String.t}
  def handle_get({:ok, %HTTPoison.Response{status_code: status_code, body: body}}) when status_code in [200, 201, 202] do
    {:ok, body}
  end
  def handle_get({:ok, %HTTPoison.Response{status_code: _, body: body}}) do
    {:error, body}
  end
  def handle_get({:error, %HTTPoison.Error{reason: reason}}) do
    {:error, reason}
  end

  @spec handle_delete(%{atom => Integer, atom => String.t}) :: {:ok, String.t} | {:error, String.t}
  def handle_delete({:ok, %HTTPoison.Response{status_code: status_code, body: body}}) when status_code in [200, 201, 202] do
    {:ok, body}
  end
  def handle_delete({:ok, %HTTPoison.Response{status_code: _, body: body}}) do
    {:error, body}
  end
  def handle_delete({:error, %HTTPoison.Error{reason: reason}}) do
    {:error, reason}
  end

  # Matching on a status_code of 200 for a PUT is a bit unexpected, but
  # CouchDB insists on returning 200 for a successful PUT when it comes
  # to creating admins.
  @spec handle_put(%{atom => Integer, atom => String.t}) :: {:ok, String.t} | {:error, String.t}
  def handle_put({:ok, %HTTPoison.Response{status_code: status_code, body: body}}) when status_code in [200, 201, 202] do
    {:ok, body}
  end
  def handle_put({:ok, %HTTPoison.Response{status_code: _, body: body}}) do
    {:error, body}
  end
  def handle_put({:error, %HTTPoison.Error{reason: reason}}) do
    {:error, reason}
  end

  @spec handle_put(%{atom => Integer, atom => String.t, atom => String.t}, atom)
    :: {:ok, String.t, String.t} | {:error, String.t, String.t | nil}
  def handle_put({:ok, %HTTPoison.Response{status_code: status_code, body: body, headers: headers}}, :include_headers) when status_code in [200, 201, 202] do
    {:ok, body, headers}
  end
  def handle_put({:ok, %HTTPoison.Response{status_code: _, body: body, headers: headers}}, :include_headers) do
    {:error, body, headers}
  end
  def handle_put({:error, %HTTPoison.Error{reason: reason}}, :include_headers) do
    {:error, reason, nil}
  end

  @spec handle_post(%{atom => Integer, atom => String.t})
    :: {:ok, String.t} | {:error, String.t}
  def handle_post({:ok, %HTTPoison.Response{status_code: status_code, body: body}}) when status_code in [200, 201, 202] do
    {:ok, body}
  end
  def handle_post({:ok, %HTTPoison.Response{status_code: _, body: body}}) do
    {:error, body}
  end
  def handle_post({:error, %HTTPoison.Error{reason: reason}}) do
    {:error, reason}
  end

  @spec handle_post(%{atom => Integer, atom => String.t, atom => String.t}, atom)
    :: {:ok, String.t, String.t} | {:error, String.t, String.t | nil}
  def handle_post({:ok, %HTTPoison.Response{status_code: status_code, body: body, headers: headers}}, :include_headers) when status_code in [200, 201, 202] do
    {:ok, body, headers}
  end
  def handle_post({:ok, %HTTPoison.Response{status_code: _, body: body, headers: headers}}, :include_headers) do
    {:error, body, headers}
  end
  def handle_post({:error, %HTTPoison.Error{reason: reason}}, :include_headers) do
    {:error, reason, nil}
  end

end
