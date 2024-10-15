# ---
# Excerpted from "Real-World Event Sourcing",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/khpes for more book information.
# ---
import Config

# A completely in-memory (TEST ONLY) event store
config :lunar_frontiers, LunarFrontiers.App.Application,
  event_store: [
    adapter: Commanded.EventStore.Adapters.EventStore,
    event_store: LunarFrontiers.EventStore
  ],
  pubsub: :local,
  registry: :local

config :lunar_frontiers, event_stores: [LunarFrontiers.EventStore]

config :lunar_frontiers, LunarFrontiers.EventStore,
  serializer: Commanded.Serialization.JsonSerializer,
  username: "postgres",
  password: "postgres",
  database: "lunar_frontiers_event_store",
  hostname: "localhost"
