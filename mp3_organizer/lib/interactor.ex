defmodule Interactor do
  @moduledoc """
  This module contains the entire communication with the user.
  """

  @doc """
  In run we check for the directory and communicate with the user until he enters the code for exit - 0.
  """
  def run do
    dir = getLastDirectory() # check if we have a directory written down in a file
    directory = switchDir(dir) # we check if the user wants to change the directory or request one
    writeDownDirectory(directory) # write down the actual directory in the file
    # task = Task.async(fn -> InnerWorkings.refreshRepeatedly(directory) end)
    printMenu()
    innerRun(1)
  end

  defp innerRun(0), do: fn -> :closed end

  defp innerRun(_) do
    readInput()
  end

  defp writeDownDirectory(directory) do
    if File.exists?("directory") do
      File.rm!("directory")
    end
    File.write("directory", directory)
  end

  defp switchDir("") do
    dir = IO.gets("Please enter an absolute path to your mp3 collection: ")
    String.trim(dir, "\n")
  end
  defp switchDir(dir) do
    IO.puts("Last used directory was " <> dir)
    IO.puts("Would you like to change the directory? y/n")
    answer = String.trim(IO.gets(""), "\n")
    if answer == "y" do
      newDir = IO.gets("Please enter a new absolute path: ")
      String.trim(newDir, "\n")
    else
      dir
    end
  end

  defp getLastDirectory do
    file = File.read("directory")
    case file do
      {:ok, dir} -> String.trim(dir, "\n")
      {:error, _} -> ""
    end
  end

  defp printMenu do
    IO.puts("Now that you have set up your directory, what would you like to do:\n
    1. List all songs, arranged by artist;
    2. List all songs, arranged by title;
    3. List all songs, arranged by album;
    4. List all songs, arranged by genre;
    5. Search for artist;
    6. Search for song;
    7. Search for album;
    8. Search by genre;
    0. Exit
    ")
  end

  defp readInput do
    {answer, _} = IO.gets("Command: ") |> Integer.parse 
    executeInput(answer)
    innerRun(answer)
  end

  defp executeInput(0), do: _ = ""
  defp executeInput(1) do
    tmp = Task.async(fn -> InnerWorkings.listArrangedByArtist(getLastDirectory()) end)
    Task.await(tmp, 90000)
  end
  defp executeInput(2) do
    tmp = Task.async(fn -> InnerWorkings.listArrangedByTitle(getLastDirectory()) end)
    Task.await(tmp, 90000)
  end
  defp executeInput(3) do
    tmp = Task.async(fn -> InnerWorkings.listArrangedByAlbum(getLastDirectory()) end)
    Task.await(tmp, 90000)
  end
  defp executeInput(5) do
    search = String.trim(IO.gets("Artist to look up: "), "\n")
    tmp = Task.async(fn -> InnerWorkings.searchByArtist(getLastDirectory(), search) end)
    Task.await(tmp, 90000)
  end
  defp executeInput(6) do
    search = String.trim(IO.gets("Title to look up: "), "\n")
    tmp = Task.async(fn -> InnerWorkings.searchByTitle(getLastDirectory(), search) end)
    Task.await(tmp, 90000)
  end
  defp executeInput(7) do
    search = String.trim(IO.gets("Album to look up: "), "\n")
    tmp = Task.async(fn -> InnerWorkings.searchByAlbum(getLastDirectory(), search) end)
    Task.await(tmp, 90000)
  end
end