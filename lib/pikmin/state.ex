defmodule Pikmin.State do
  @name __MODULE__

  # Agentのスタート
  def start_link do
    { :ok, pid } = Agent.start_link(fn -> %{} end, name: @name)
    update(:redmine_updated_on)
    { :ok, pid }
  end

  # 最終問合せ日時を取得
  def get(:redmine_updated_on), do: Agent.get(@name, fn map -> map[:redmine_updated_on] end)

  # 最終問合せ日時を現在日時で更新
  def update(:redmine_updated_on) do
    now_of_iso = DateTime.utc_now()
                |> truncate_second
                |> DateTime.to_iso8601()
    Agent.update(@name, fn map -> Map.put(map, :redmine_updated_on, now_of_iso) end)
  end

  # msを切る
  defp truncate_second(datetime) do
    %{datetime | microsecond: {0, 0}}
  end
end
