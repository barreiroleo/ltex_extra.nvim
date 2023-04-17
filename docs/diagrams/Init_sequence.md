# Sequence
`cat architecture.md | plantuml_asci`

@startuml
nvim -> ltex_extra : load
ltex_extra -> nvim : is ltex running?
nvim -> ltex_extra : ltex status
ltex_extra -> ltex : start
@enduml

     ┌────┐          ┌──────────┐          ┌────┐
     │nvim│          │ltex_extra│          │ltex│
     └─┬──┘          └────┬─────┘          └─┬──┘
       │       load       │                  │
       │ ─────────────────>                  │
       │                  │                  │
       │ is ltex running? │                  │
       │ <─────────────────                  │
       │                  │                  │
       │    ltex status   │                  │
       │ ─────────────────>                  │
       │                  │                  │
       │                  │       start      │
       │                  │ ─────────────────>
     ┌─┴──┐          ┌────┴─────┐          ┌─┴──┐
     │nvim│          │ltex_extra│          │ltex│
     └────┘          └──────────┘          └────┘

@startuml
nvim -> ltex_extra : load
ltex_extra -> nvim : is ltex running?
nvim -> ltex_extra : ltex status
ltex_extra -> ltex : ltex is already running
@enduml

     ┌────┐          ┌──────────┐                ┌────┐
     │nvim│          │ltex_extra│                │ltex│
     └─┬──┘          └────┬─────┘                └─┬──┘
       │       load       │                        │
       │ ─────────────────>                        │
       │                  │                        │
       │ is ltex running? │                        │
       │ <─────────────────                        │
       │                  │                        │
       │    ltex status   │                        │
       │ ─────────────────>                        │
       │                  │                        │
       │                  │ ltex is already running│
       │                  │ ───────────────────────>
     ┌─┴──┐          ┌────┴─────┐                ┌─┴──┐
     │nvim│          │ltex_extra│                │ltex│
     └────┘          └──────────┘                └────┘
