defmodule Eventful.TransitionsTest do
  use Eventful.DataCase

  alias Eventful.Test.{
    Model,
    Actor
  }

  setup do
    {:ok, model} =
      %Model{}
      |> Model.changeset(%{})
      |> Repo.insert()

    {:ok, actor} =
      %Actor{}
      |> Actor.changeset(%{name: "zack"})
      |> Repo.insert()

    {:ok, %{model: model, actor: actor}}
  end

  describe "transition successfully" do
    test "can transition", %{model: model, actor: actor} do
      assert {:ok, transaction} =
               Model.Event.handle(model, actor, %{
                 domain: "transitions",
                 name: "process"
               })

      assert transaction.resource.current_state == "processing"
    end

    test "can transition with trigger", %{model: model, actor: actor} do
      Model.Event.handle(model, actor, %{
        domain: "transitions",
        name: "process"
      })

      model = Repo.get(Model, model.id)

      assert {:ok, transaction} =
               Model.Event.handle(model, actor, %{
                 domain: "transitions",
                 name: "approve"
               })

      assert transaction.trigger == :something_got_triggered
    end

    test "can access events from model", %{model: model, actor: actor} do
      Model.Event.handle(model, actor, %{
        domain: "transitions",
        name: "process"
      })

      model =
        Model
        |> Repo.get(model.id)
        |> Repo.preload([:events])

      assert Enum.count(model.events) == 1
    end
  end

  describe "transition failure" do
    test "should not transition if event name is wrong", %{
      model: model,
      actor: actor
    } do
      assert {:error, :invalid_transition_event} =
               Model.Event.handle(model, actor, %{
                 domain: "transitions",
                 name: "weird"
               })
    end
  end

  describe "transition with comment" do
    test "can transition with comment", %{model: model, actor: actor} do
      comment = "did something"

      assert {:ok, transaction} =
               Model.Event.handle(model, actor, %{
                 domain: "transitions",
                 name: "process",
                 comment: comment
               })

      assert transaction.event.metadata.comment == comment
    end

    test "can transition with nil comment", %{model: model, actor: actor} do
      assert {:ok, transaction} =
               Model.Event.handle(model, actor, %{
                 domain: "transitions",
                 name: "process",
                 comment: nil
               })

      refute Map.has_key?(transaction.event.metadata, :comment)
    end
  end
end
