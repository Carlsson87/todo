# Todo

This is pretty much what happens after "Hello World". One builds a todo-app.

## Full disclosure

This project was built using [Haskell Stack](https://docs.haskellstack.org/en/stable/README/) because I read somewhere that it was the recommended approach.

# Usage

You need to have [Haskell Stack](https://docs.haskellstack.org/en/stable/README/) installed.
```
stack build
```

This will build the project. To run the application:
(Currently the app expects the file `~/.todo` to exist, so make sure it exists)

```
stack exec todo-exe help
```

This will display all the available commands:

```
add 	Add an item
check	Mark an item as completed
purge	Remove all completed items
clear	Remove all items
help	You're looking at it
```


So there. I made something.


## Todo
- [ ] Put data in a data-file.
