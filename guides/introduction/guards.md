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
    fn changes -> transit(changes, Post.Triggers) end)
  )

  defp guard_transition(%Post{current_state: _current_state} = post, _user_, "publish") do
    if MyApp.check_something(post),
      do: {:ok, :passed},
      else: {:error, :failed}
  end

  defp guard_transition(_post_, _user, _), do: {:ok, :passed}
end
```

This allows you to define that a given condition computed by `MyApp.check_something/1` will need to return true when `publish` event is invoked.