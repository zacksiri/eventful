defmodule Eventful.TransitionsTest do
  @moduledoc false

  use Eventful.DataCase

  alias Eventful.Test.{
    Model,
    Actor,
    User
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

    {:ok, user} =
      %User{}
      |> User.changeset(%{name: "zack"})
      |> Repo.insert()

    {:ok, model: model, actor: actor, user: user}
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

    test "can transition using publishings", %{model: model, actor: actor} do
      assert {:ok, transaction} =
               Model.Event.handle(model, actor, %{
                 domain: "publishings",
                 name: "publish"
               })

      assert transaction.resource.publish_state == "published"
    end

    test "can transition internal", %{model: model, user: user} do
      assert {:ok, transaction} =
               Model.InternalEvent.handle(model, user, %{
                 domain: "internal_transitions",
                 name: "activate"
               })

      assert transaction.resource.internal_state == "active"
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

  describe "transitions" do
    test "get all transitions", %{model: _model} do
      assert Enum.count(Model.Transitions.all()) == 2
    end
  end

  describe "valid states" do
    test "list unique valid states", %{model: _model} do
      assert Enum.sort(Model.Transitions.valid_states()) == [
               "approved",
               "created",
               "processing"
             ]
    end
  end

  describe "show possible events" do
    test "show all possible events for a given model", %{model: model} do
      assert Model.Transitions.possible_events(model) == [
               %{from: "created", to: "processing", via: "process"}
             ]
    end
  end
end
