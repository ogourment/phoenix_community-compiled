defmodule Mix.Tasks.Compile.BinaryPhoenixCommunity do
  use Mix.Task.Compiler
  @moduledoc false
  @root __DIR__
  @checksums %{
    "ebin/Elixir.PhoenixCommunity.Admission.beam" =>
      "4311873BA6866B637C3B74F7473FC1021B7F4973FF8ABE61B0643DF1CD8A3A50",
    "ebin/Elixir.PhoenixCommunity.Content.beam" =>
      "93D9ECD7F8E12E36FF9C8387FE8AEE3FEDC789B8B9EEF1E60D47C2C5B64C0CC9",
    "ebin/Elixir.PhoenixCommunity.Meetings.LiveKit.beam" =>
      "DE13C556DDF000E629FA7B368E9A0A5AA1C5426D4699D1FFF3820488ECA30BA2",
    "ebin/Elixir.PhoenixCommunity.Outbox.beam" =>
      "4BFF4700925E7428A2B8441454B615D4B91005E27EEE95AECF9B3671634285F8",
    "ebin/Elixir.PhoenixCommunity.Slack.API.beam" =>
      "A2A7507A301F7DA241E46BFEC34CBD3FCFF16211AF8DB1DEFB3054E042C105E0",
    "ebin/Elixir.PhoenixCommunity.Slack.Inbox.beam" =>
      "6CF5472C7E602E4C465656D46075E2ADB0A54505D22CCDEA160935B3DA0FC562",
    "ebin/Elixir.PhoenixCommunity.Slack.Message.beam" =>
      "C8167E7D0C8EE25EA12869D932559A8F9334A7AC9F8CD18FEA73BC2B81EEF0E3",
    "ebin/Elixir.PhoenixCommunity.Slack.OAuth.beam" =>
      "25419DC1EAA0517D517BA1EB08D326E78AA068B174CFC45495A5AE484D3DB46A",
    "ebin/Elixir.PhoenixCommunity.Slack.Signature.beam" =>
      "11F5CE4BE7F348244FC0F6284CC390BB9F12FA3B5CBFF9A6F6391F1D73AA0313",
    "ebin/Elixir.PhoenixCommunity.Store.beam" =>
      "D46E4A171147E152AEE07A1B069511703F8CA9A85DDEC622D4B8CA4D43EE1468",
    "ebin/phoenix_community.app" =>
      "F3FA8C6111CAE4EFFC98D3D1FD6442B9033A3CC90F079DACC9310057B3BFF36F"
  }

  @impl true
  def run(_args) do
    series = Version.parse!(System.version()) |> Map.take([:major, :minor])

    unless series == %{major: 1, minor: 20} and System.otp_release() == "29" do
      Mix.raise("phoenix_community requires a binary distribution for Elixir 1.20.x / OTP 29")
    end

    for {path, expected} <- @checksums do
      bytes = File.read!(Path.join(@root, path))

      unless Base.encode16(:crypto.hash(:sha256, bytes)) == expected do
        Mix.raise("phoenix_community artifact checksum mismatch: #{path}")
      end

      if String.starts_with?(path, "ebin/") do
        target = Path.join(Mix.Project.compile_path(), Path.basename(path))
        File.mkdir_p!(Path.dirname(target))
        File.write!(target, bytes)
      end
    end

    {:ok, []}
  end
end

defmodule Compiled.PhoenixCommunity.MixProject do
  use Mix.Project

  def project do
    [
      app: :phoenix_community,
      version: "0.0.4",
      elixir: "~> 1.20.0",
      compilers: [:binary_phoenix_community],
      deps: [jason: "~> 1.4", joken: "~> 2.7", ecto: "~> 3.14", plug_crypto: "~> 2.1"]
    ]
  end

  def application, do: [extra_applications: [:crypto]]
end
