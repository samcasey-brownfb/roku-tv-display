sub init()
    m.poster = m.top.findNode("displayImage")

    m.playlistTask = CreateObject("roSGNode", "PlaylistTask")
    m.playlistTask.observeField("playlistData", "onPlaylistLoaded")
    m.playlistTask.control = "RUN"
end sub

sub onPlaylistLoaded()
    data = m.playlistTask.playlistData

    if data <> invalid and data.items <> invalid and data.items.Count() > 0
        firstItem = data.items[0]

        if firstItem.type = "image"
            m.poster.uri = firstItem.url
        end if
    end if
end sub
