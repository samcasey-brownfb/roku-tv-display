sub init()
    m.poster = m.top.findNode("displayImage")
    loadPlaylist()
end sub

sub loadPlaylist()
    url = "https://raw.githubusercontent.com/samcasey-brownfb/roku-tv-display/main/playlist.json"

    request = CreateObject("roUrlTransfer")
    request.SetUrl(url)

    response = request.GetToString()

    if response <> invalid and response <> ""
        data = ParseJson(response)

        if data <> invalid and data.items <> invalid and data.items.Count() > 0
            firstItem = data.items[0]

            if firstItem.type = "image"
                m.poster.uri = firstItem.url
            end if
        end if
    end if
end sub
