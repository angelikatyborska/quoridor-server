# Quoridor Websocket Server

## Notifications

### LOBBY_UPDATE

Sent to everyone in the lobby when:
- a new player joins the lobby,
- a new room is created,
- a player joins a room,

```json
{
  "type": "LOBBY_UPDATE",
  "data": {
    "players_in_lobby": [],
    "rooms": [
      {
        "capacity": 4,
        "spots_left": 2,
        "players": [
          {"id": "iGIjiy6k07COG8TdZ0ZHiA==", "nickname": "Carl"},
          {"id": "EE9cjSHNmf20CQTra1yRNQ==", "nickname": "Kate"}
        ],
        "owner": {"id": "iGIjiy6k07COG8TdZ0ZHiA==", "nickname": "Carl"}
      }
    ]
  }
}
```

## Messages 

### JOIN (the lobby)
#### Request
```json
{
  "type": "JOIN",
  "data": {
    "nickname": "John"
  }
}
```

#### Response
```json
{
  "type":"JOINED",
  "data": {
    "id": "coIl9V+Az54xZjhcYwcFyg==",
    "nickname": "John"
  }
}
```