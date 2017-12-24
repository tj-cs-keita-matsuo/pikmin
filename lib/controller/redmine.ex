defmodule Controller.Redmine do
  # redmine用のconfigを取得し、パラメーターを返す
  def config() do
    [ base_url: base_url, api_key: api_key ] = Application.get_all_env(:pikmin)[:redmine]
    %{ base_url: base_url, headers: [{"X-Redmine-API-Key", api_key}] }
  end

  # チケット、ジャーナル情報を取得する
  def get(:new_journals) do
    # 最終問合せ日の取得
    updated_on = Pikmin.State.get(:redmine_updated_on)

    # redmineへの問合せ
    response = issues(updated_on)
              |> journals
              |> filter(updated_on)
              |> take_create

    # 最終問合せ日時の更新
    Pikmin.State.update(:redmine_updated_on)

    # 取得データを返す
    response
  end

  # クローズしてないチケットを取得
  # 調べたところ、journalsの編集では更新されない。新規journalsは更新される
  def issues(updated_on) do
    %{ base_url: base_url, headers: headers } = config()

    url = base_url <> "issues.json?status_id=open&updated_on=%3E%3D#{updated_on}"
    HTTPoison.get!(url, headers)
    |> take_body
    |> Poison.decode!
    |> take_issues
  end

  # チケットを回し、コメントを取得する
  def journals(issues) do
    %{ base_url: base_url, headers: headers } = config()

    Enum.flat_map(issues, fn(%{ "id" => id }) ->
      # TODO: issueからアカウントID、アカウント名、アカウントコードを抜きたい
      url = base_url <> "issues/#{id}.json?include=attachments,journals"

      HTTPoison.get!(url, headers)
      |> take_body
      |> Poison.decode!
      |> take_journals
      |> Enum.sort(fn(j1, j2) -> j1["created_on"] < j2["created_on"] end)
      |> Enum.with_index(1)
      |> Enum.map(fn { journal, i } ->
        Map.merge(journal, %{ "number" => i, "issue" => %{ "id" => id } })
      end)
    end)

  end

  # コメントを絞る
  def filter(journals, updated_on) do
    Enum.filter(journals, fn(%{ "created_on" => created_on, "notes" => notes }) ->
      created_on >= updated_on && notes != ""
    end)
  end

  # コメントから必要なものを抽出する
  def take_create(journals) do
    %{ base_url: base_url } = config()

    Enum.map(journals,
      fn(%{ "number" => number, "notes" => notes,
            "user" => %{ "name" => name },
            "issue" => %{ "id" => issue_id } }) ->
        %{ name: name, notes: notes, ticket: "#{base_url}issues/#{issue_id}#note-#{number}" }
      end
    )
  end

  defp take_body(%{ status_code: 200, body: body }), do: body
  defp take_issues(%{ "issues" => issues }), do: issues
  defp take_journals(%{ "issue" => %{ "journals" => journals } }), do: journals
end
