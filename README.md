# AshJoinBug

## How to run this
There's an optional Nix flake included with all required dependencies, including Postgres and Mariadb with a script to run it in the current directory (`startpostgresql`/`startmariadb`).

1. Start Postgresql and Mariadb.
2. Adjust `config/config.exs` connection settings as needed.
3. Fetch dependencies with `mix deps.get`.
4. Create and migrate the databases with `mix ash.setup`.
5. Seed the tables with `mix run priv/seeds.exs`.
6. Run `iex -S mix`.
7. Interact with the resources `AshJoinBug.Resources.Resource1Mysql` and `AshJoinBug.Resources.Resource1PG` to observe the bug. Specifically the `read_with_filtered_external_relationship` interfaces.

## The problem

Ash seems to generate incorrect queries when joining _and_ filtering a relationship that exists on a different data layer. 

In this example there are 4 rows in every table. Filtering should reduce that to 2 rows, but we get 0. The relationship happens between Postgresql and Mysql data layers, but the generated query appears to be incorrect for either one.

Confirm that the relationship works and is joined on correctly.
```
iex> AshJoinBug.Resources.Resource1PG.read_with_external_relationship! |> Enum.count

01:53:12.954 [debug] QUERY OK source="resource1pg" db=0.5ms idle=1996.6ms
SELECT r0."id", r0."resource2_id", r0."value" FROM "resource1pg" AS r0 []

01:53:12.954 [debug] QUERY OK source="resource2mysql" db=0.3ms idle=1976.6ms
SELECT r0.`id`, r0.`resource1_id`, r0.`value` FROM `resource2mysql` AS r0 WHERE (CAST(r0.`resource1_id` AS binary(16)) IN (CAST(? AS binary(16)),CAST(? AS binary(16)),CAST(? AS binary(16)),CAST(? AS binary(16)))) ["3ce62794-4e9c-4b73-b77c-28553a30eb49", "437749d3-9a4f-4a29-9857-d38ee31716df", "48013e2e-3ca6-4865-8834-8ee33e5cb43e", "fdbdada6-a1f2-4741-83a3-c09dd84dd4ea"]

4
```
We get 4 results, as expected.

Now with a filter.
```
iex> AshJoinBug.Resources.Resource1PG.read_with_filtered_external_relationship! |> Enum.count

01:44:58.211 [debug] QUERY OK source="resource2mysql" db=7.9ms queue=0.2ms idle=1225.4ms
SELECT r0.`id`, r0.`resource1_id`, r0.`value` FROM `resource2mysql` AS r0 WHERE (CAST(r0.`value` AS char) = CAST(? AS char)) ["other-value-0"]

01:44:58.216 [debug] QUERY OK source="resource1pg" db=1.1ms queue=2.3ms idle=1258.9ms
SELECT r0."id", r0."resource2_id", r0."value" FROM "resource1pg" AS r0 WHERE (r0."id"::uuid = $1::uuid) AND (r0."id"::uuid = $2::uuid) ["3ce62794-4e9c-4b73-b77c-28553a30eb49", "fdbdada6-a1f2-4741-83a3-c09dd84dd4ea"]

0
```
We get 0 results, but we should have gotten 2.

It looks like the problem is that the `WHERE` is generated with `AND` instead of `IN` or `OR`, resulting in an impossible condition.

Of course, this does not happen when the relationship exists on the same data layer.
```
iex> AshJoinBug.Resources.Resource1PG.read_with_filtered_relationship! |> Enum.count

02:18:16.087 [debug] QUERY OK source="resource1pg" db=0.3ms queue=0.4ms idle=1130.0ms
SELECT r0."id", r0."resource2_id", r0."value" FROM "resource1pg" AS r0 INNER JOIN "public"."resource2pg" AS r1 ON r0."id" = r1."resource1_id" WHERE (r1."value"::text = $1::text) ["other-value-0"]

02:18:16.088 [debug] QUERY OK source="resource2pg" db=0.3ms idle=1131.5ms
SELECT r0."id", r0."resource1_id", r0."value" FROM "resource2pg" AS r0 WHERE (r0."resource1_id"::uuid = ANY($1::uuid[])) [["3ce62794-4e9c-4b73-b77c-28553a30eb49", "fdbdada6-a1f2-4741-83a3-c09dd84dd4ea"]]

2
```

For completeness sake, the same problem can be observed on final queries generated for Mysql.
```
iex> AshJoinBug.Resources.Resource1Mysql.read_with_filtered_external_relationship! |> Enum.count

02:18:45.563 [debug] QUERY OK source="resource2pg" db=0.4ms idle=1605.8ms
SELECT r0."id", r0."resource1_id", r0."value" FROM "resource2pg" AS r0 WHERE (r0."value"::text = $1::text) ["other-value-0"]

02:18:45.564 [debug] QUERY OK source="resource1mysql" db=0.5ms idle=1585.6ms
SELECT r0.`id`, r0.`resource2_id`, r0.`value` FROM `resource1mysql` AS r0 WHERE (CAST(r0.`resource2_id` AS binary(16)) = CAST(? AS binary(16))) AND (CAST(r0.`resource2_id` AS binary(16)) = CAST(? AS binary(16))) ["066076e5-8350-4f8a-b21a-db0244796d9e", "b9712aa2-98be-4df7-9209-be6acc505f48"]

0
```