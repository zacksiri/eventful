# Guards

Guards are useful when you wish to prevent your transition from happening based on some kind of check.

In your `Transitions` module you can define guards like so:

```
defmodule MyApp.Post.Transitions do
  alias MyApp.Post

  @behaviour Eventful.Handler

  use Eventful.Transition, repo: MyApp.Repo

  Post
  |> transition(
    [from: "draft", to: "published", via: "publish"],
    fn {post_changeset, _} = changes ->
      if MyApp.check_something(post_changeset.data) do
        transit(changes, Post.Triggers)
      else
        {:error, "guard failed"}
      end
    end)
  )
end
```

This allows you to define that a given condition computed by `MyApp.check_something/1` will need to return true when `publish` event is invoked.
