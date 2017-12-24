defmodule Controller.Slack do
  # Slackのconfig関係を取得
  def config() do
    Enum.into(Application.get_all_env(:pikmin)[:slack], %{})
  end

  # 送信データのリストを受け取って、Slackへ送信
  def send_message(messages) when is_list(messages) do
    %{ base_url: base_url, token: token } = config()

    params = %{
      url: base_url <> "chat.postMessage",
      headers: [{ "Content-type", "application/json" }, { "Authorization", "Bearer " <> token }]
    }

    Enum.map(messages, fn message ->
      Map.merge(message, %{ "username" => "redmine bot", "icon_emoji" => ":bow:" })
      |> send_message(params)
    end)
  end

  # Slackへjsonデータを送信する
  def send_message(message, %{ url: url, headers: headers }) when is_map(message) do
    HTTPoison.post(url, message |> Poison.encode! , headers, [])
    |> take_body
    |> Poison.decode!
  end

  defp take_body({ :ok, %{ status_code: 200, body: body } }), do: body
end
