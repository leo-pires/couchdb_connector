defmodule Couchdb.Connector.Writer do
  @moduledoc """
  The Writer module provides functions to create and update documents in
  the CouchDB database given by the database properties.

  ## Examples

      db_props = %{protocol: "http", hostname: "localhost",database: "couchdb_connector_test", port: 5984}
      %{database: "couchdb_connector_test", hostname: "localhost", port: 5984, protocol: "http"}

      Couchdb.Connector.Storage.storage_up(db_props)
      {:ok, "{\\"ok\\":true}\\n"}

      Couchdb.Connector.Writer.create(db_props, "{\\"key\\": \\"value\\"}")
      {:ok, "{\\"ok\\":true,\\"id\\":\\"7dd00...\\",\\"rev\\":\\"1-59414e7...\\"}\\n",
            [{"Server", "CouchDB/1.6.1 (Erlang OTP/18)"},
             {"Location", "http://localhost:5984/couchdb_connector_test/7dd00..."},
             {"ETag", "\\"1-59414e7...\\""}, {"Date", "Mon, 21 Dec 2015 16:13:23 GMT"},
             {"Content-Type", "text/plain; charset=utf-8"},
             {"Content-Length", "95"}, {"Cache-Control", "must-revalidate"}]}

  """

  alias Couchdb.Connector.Types
  alias Couchdb.Connector.Request
  alias Couchdb.Connector.Headers
  alias Couchdb.Connector.Reader
  alias Couchdb.Connector.UrlHelper
  alias Couchdb.Connector.ResponseHandler, as: Handler

  @doc """
  Create a new document with given json and given id.
  Clients must make sure that the id has not been used for an existing document
  in CouchDB.
  Either provide a UUID or consider using create_generate in case uniqueness cannot
  be guaranteed.
  """
  @spec create(Types.db_properties, String.t, String.t)
    :: {:ok, String.t, Types.headers} | {:error, String.t, Types.headers}
  def create(db_props, json, id) do
    db_props
    |> UrlHelper.document_url(id)
    |> do_create(json)
  end

  @doc """
  Create a new document with given json and a CouchDB generated id.
  Fetching the uuid from CouchDB does of course incur a performance penalty as
  compared to providing one.
  """
  @spec create_generate(Types.db_properties, String.t)
    :: {:ok, String.t, Types.headers} | {:error, String.t, Types.headers}
  def create_generate(db_props, json) do
    {:ok, uuid_json} = Reader.fetch_uuid(db_props)
    uuid = hd(Poison.decode!(uuid_json)["uuids"])
    create(db_props, json, uuid)
  end

  defp do_create(url, json) do
    Request.put(url, json, [Headers.json_header])
    |> Handler.handle_put(:include_headers)
  end

  @doc """
  Update the given document that is stored under the given id.
  """
  @spec update(Types.db_properties, String.t, String.t)
    :: {:ok, String.t, Types.headers} | {:error, String.t, Types.headers}
  def update(db_props, json, id) do
    db_props
    |> UrlHelper.document_url(id)
    |> do_update(json)
  end

  @doc """
  Update the given document.
  Note that an _id field must be contained in the document.
  A missing _id field will trigger a RuntimeError.
  """
  @spec update(Types.db_properties, String.t)
    :: {:ok, String.t, Types.headers} | {:error, String.t, Types.headers}
  def update(db_props, json) do
    {doc_map, id} = parse_and_extract_id(json)
    case id do
      {:ok, id} ->
        db_props
        |> UrlHelper.document_url(id)
        |> do_update(Poison.encode!(doc_map))
      :error ->
        raise RuntimeError, message:
          "the document to be updated must contain an \"_id\" field"
    end
  end

  defp do_update(url, json) do
    url
    |> Request.put(json, [Headers.json_header])
    |> Handler.handle_put(:include_headers)
  end

  defp parse_and_extract_id(json) do
    doc_map = Poison.Parser.parse!(json)
    {doc_map, Map.fetch(doc_map, "_id")}
  end

  @doc """
  Delete the document with the given id in the given revision.
  An error will be returned in case the document does not exist or the
  revision is wrong.
  """
  @spec destroy(Types.db_properties, String.t, String.t)
    :: {:ok, String.t} | {:error, String.t}
  def destroy(db_props, id, rev) do
    db_props
    |> UrlHelper.document_url(id)
    |> do_destroy(rev)
  end

  defp do_destroy(url, rev) do
    Request.delete(url <> "?rev=#{rev}")
    |> Handler.handle_delete
  end

  @doc """
  TODO: write!
  """
  @spec bulk_docs(Types.db_properties, map, boolean) :: {:ok, String.t} | {:error, String.t}
  def bulk_docs(db_props, docs, new_edits \\ true) do
    body = %{docs: docs, new_edits: new_edits} |> Poison.encode!
    db_props
    |> UrlHelper.bulk_docs_url
    |> Request.post(body, [{"Content-Type", "application/json; charset=utf-8"}])
    |> Handler.handle_post(:include_headers)
  end
end
