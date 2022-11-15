# Triggers

Triggers are a powerful way to trigger some action that you define when a certain event occurs. Let's take a look at an example. Let's assume you have the following `Transitions` module.

```
defmodule MyApp.Post.Transitions do
  use Eventful.Transition, repo: MyApp.Repo
  
  @behaviour Eventful.Handler
  
  alias MyApp.Post
  
  Post
  |> transition([from: "draft", to: "published", via: "publish", fn changes ->
    transit(changes)
  end)
  
  Post
  |> transition([from: "published", to: "draft", via: "drafting", fn changes ->
    transit(changes)
  end)
end
```

Let's say that when a post is `published` you would like your app to fire an email to notify someone that a post has been `published`.

You could define a trigger like this:

```
defmodule MyApp.Post.Triggers do
  alias MyApp.Post

  use Eventful.Trigger

  Post
  |> trigger([currently: "published"], fn event, post ->
    # user code to send email
  end)
end
```

You will also need to update your `Transitions` module like so:

```
defmodule MyApp.Post.Transitions do
  use Eventful.Transition, repo: MyApp.Repo
  
  @behaviour Eventful.Handler
  
  alias MyApp.Post
  
  Post
  |> transition([from: "draft", to: "published", via: "publish", fn changes ->
    transit(changes, Post.Triggers)
  end)
  
  Post
  |> transition([from: "published", to: "draft", via: "drafting", fn changes ->
    transit(changes)
  end)
end
```

Now every time a post is published it will send the email notification.