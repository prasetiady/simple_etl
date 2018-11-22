# SimpleEtl

Install dependencies
  ```
  mix deps.get
  ```

Setup database for testing
  ```
  mix ecto.create
  mix ecto.migrate
  ```

Run test for manager
  ```
  mix test test/simple_etls/manager_test.exs
  ```
		