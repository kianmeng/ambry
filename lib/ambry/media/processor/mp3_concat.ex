defmodule Ambry.Media.Processor.MP3Concat do
  @moduledoc """
  A media processor that concatenates a collection of MP3 files and then
  converts them to dash streaming format.
  """

  import Ambry.Paths

  alias Ambry.Media

  def can_run?(media) do
    media |> mp3_files() |> length() > 1
  end

  def run(media) do
    filename = concat_mp3!(media)
    create_mpd!(media, filename)
    finalize!(media, filename)
  end

  defp mp3_files(media) do
    media.source_path
    |> File.ls!()
    |> Enum.filter(&(Path.extname(&1) == ".mp3"))
  end

  defp concat_mp3!(media) do
    file_list_txt_path = Path.join([media.source_path, "files.txt"])

    file_list_txt =
      media
      |> mp3_files()
      |> Enum.sort()
      |> Enum.map_join("\n", &"file '#{&1}'")

    File.write!(file_list_txt_path, file_list_txt)

    filename = Ecto.UUID.generate()
    command = "ffmpeg"
    args = ["-f", "concat", "-safe", "0", "-i", "files.txt", "#{filename}.mp4"]

    {_output, 0} = System.cmd(command, args, cd: media.source_path, parallelism: true)

    filename
  end

  defp create_mpd!(media, filename) do
    command = "shaka-packager"

    args = [
      "in=#{filename}.mp4,stream=audio,out=#{filename}.mp4",
      # "--dash_force_segment_list",
      "--base_urls",
      "/uploads/media/",
      "--mpd_output",
      "#{filename}.mpd"
    ]

    {_output, 0} = System.cmd(command, args, cd: media.source_path, parallelism: true)
  end

  defp finalize!(media, filename) do
    media_folder = Path.join(uploads_path(), "media")
    mpd_dest = Path.join([media_folder, "#{filename}.mpd"])
    mp4_dest = Path.join([media_folder, "#{filename}.mp4"])

    File.mkdir_p!(media_folder)

    File.rename!(
      Path.join(media.source_path, "#{filename}.mpd"),
      mpd_dest
    )

    File.rename!(
      Path.join(media.source_path, "#{filename}.mp4"),
      mp4_dest
    )

    Media.update_media(media, %{
      mpd_path: "/uploads/media/#{filename}.mpd",
      mp4_path: "/uploads/media/#{filename}.mp4",
      status: :ready
    })
  end
end
