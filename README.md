# Quoridor Websocket Server

## Setup

```
bundle install
thin start
```

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

##### Success

```json
{
  "type":"JOINED",
  "data": {
    "id": "coIl9V+Az54xZjhcYwcFyg==",
    "nickname": "John"
  }
}
```

##### Error

```json
{
  "type":"ERROR",
  "data": "An unique nickname is required"
}
```

### CREATE_ROOM

#### Request

```json
{
  "type": "CREATE_ROOM",
  "data": {
    "capacity": "2"
  }
}
```

#### Response

##### Success

```json
{
  "type":"CREATED_ROOM",
  "data": {
    "id": "QfgbbT90gF/Bd0ZAyhHItw==",
    "capacity": 2,
    "spots_left": 1,
    "owner": {
      "id": "coIl9V+Az54xZjhcYwcFyg==",
      "nickname": "John"
    }
    "players": [
      {
        "id": "coIl9V+Az54xZjhcYwcFyg==",
        "nickname": "John"
      }
    ]
  }
}
```

##### Error

```json
{
  "type": "ERROR",
  "data": "Malformed message {}: capacity cannot be blank"
}
```

### JOIN_ROOM

#### Request
```json
{
  "type": "JOIN_ROOM",
  "data": {
    "room_id": "hJ7pjiiEAYekYP4GUWYo1w=="
  }
}
```

#### Response

##### Success

```json
{
  "type":"JOINED_ROOM",
  "data": {
    "id": "QfgbbT90gF/Bd0ZAyhHItw==",
    "capacity": 2,
    "spots_left": 0,
    "owner": {
      "id": "coIl9V+Az54xZjhcYwcFyg==",
      "nickname": "John"
    }
    "players": [
      {
        "id": "coIl9V+Az54xZjhcYwcFyg==",
        "nickname": "John"
      },
      {
        "id": "iCwj2XJeLEYIfSjmGNcSpQ==",
        "nickname": "Mary"
      }
    ]
  }
}
```

##### Error

```json
{
  "type":"ERROR",
  "data": "Malformed message {"room_id"=>"abc"}: room with id abc not found"
}
```

### LEAVE_ROOM

#### Request
```json
{
  "type": "LEAVE_ROOM",
  "data": {
    "room_id": "hJ7pjiiEAYekYP4GUWYo1w=="
  }
}
```

#### Response

##### Success

```json
{
  "type":"LEFT_ROOM",
  "data": {
    "id": "QfgbbT90gF/Bd0ZAyhHItw==",
    "capacity": 2,
    "spots_left": 2,
    "owner": {
      "id": "coIl9V+Az54xZjhcYwcFyg==",
      "nickname": "John"
    }
    "players": []
  }
}
```

##### Error

```json
{
  "type":"ERROR",
  "data": "Malformed message {"room_id"=>"abc"}: room with id abc not found"
}
```
