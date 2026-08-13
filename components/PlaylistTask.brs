sub init()
    m.top.functionName = "loadPlaylist"
end sub

sub loadPlaylist()
    url = "https://raw.githubusercontent.com/samcasey-brownfb/roku-tv-display/main/playlist.json"

    request = CreateObject("roUrlTransfer")
    request.SetCertificatesFile("common:/certs/ca-bundle.crt")
    request.InitClientCertificates()
    request.SetUrl(url)

    response = request.GetToString()

    if response <> invalid and response <> ""
        data = ParseJson(response)

        if data <> invalid
            m.top.playlistData = data
        end if
    end if
end sub
