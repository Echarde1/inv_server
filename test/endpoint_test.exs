defmodule InvEndpointTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts Inv.Endpoint.init([])

  test "returns hello world" do
    conn = conn(:get, "/hello")
    conn = Inv.Endpoint.call(conn, @opts)
    mock_message_text = "Привет от Даньки!! Скоро он научит меня выгружать данные по облигациям и отправлять их в табличку"

    assert conn.request_path == "/hello"
    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == Poison
      .encode!(
       create_response_message_text(mock_message_text)
      )
  end

  defp create_response_message_text(message) do
    %{
      text: "#{message}"
    }
  end
end
