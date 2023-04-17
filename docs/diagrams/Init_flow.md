# Initial flow

Generated with [Diagon](https://arthursonzogni.com/Diagon/#Flowchart)

```
"START";
if("Should be load ltex?"){
    if("Ltex is running?"){
        "Load ltex from lspconfig";
    }
    else{
        "Alert ltex already running";
    }
}
else{
    "Load plugins opts and attach to a running ltex instance"
}
"END";
```

```
            ┌─────┐
            │START│
            └──┬──┘
      _________▽__________       ________________     ┌──────────────┐
     ╱                    ╲     ╱                ╲    │Load ltex from│
    ╱ Should be load ltex? ╲___╱ Ltex is running? ╲___│lspconfig     │
    ╲                      ╱yes╲                  ╱yes└───────┬──────┘
     ╲____________________╱     ╲________________╱            │
               │no                      │no                   │
┌──────────────▽─────────────┐  ┌───────▽───────┐             │
│Load plugins opts and attach│  │Alert ltex     │             │
│to a running ltex instance  │  │already running│             │
└──────────────┬─────────────┘  └───────┬───────┘             │
               └────────────┬───────────┴─────────────────────┘
                          ┌─▽─┐
                          │END│
                          └───┘
```
