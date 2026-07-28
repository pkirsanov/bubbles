"""Every endpoint the client calls is registered here."""

ROUTES = [
    ("/api/v1/records", "POST", "submit_record"),
    ("/api/v1/records/limits", "GET", "read_limits"),
]
