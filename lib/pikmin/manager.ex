defmodule Pikmin.Manager do
  # 問合せを実行し、Slackへ展開
  def run() do
    IO.puts "run redmine to slack"
    Controller.Redmine.get(:new_journals)
    |> create_message
    |> Controller.Slack.send_message
  end

  # Redmineから取得したデータをもろもろ判断し、Slackに送信できる形に変換する
  def create_message(journals) do
    Enum.map(journals, fn %{ name: name, notes: notes, ticket: ticket } ->
      message = """
      <!here>
      対応者：#{name}
      チケット：#{ticket}
      内容：#{notes}
      """
      %{ "channel" => "general", "text" => message }
    end)
  end
end
