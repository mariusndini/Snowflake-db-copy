# Snowflake-db-copy
Snowflake stored procedure to copy data from one DB to another DB

Stored Procedure is intended to copy data from source DB/Schema into target DB/Schema within Snowflake. Please be mindful that stored procedure will create materalized views. Logic will only copy tables currently and not views. MVs also cannot reference views. 

<b>SHARE_MV_CREATE(DB_SRC STRING, SCHEMA_SRC STRING, DB_DEST STRING, SCHEMA_DEST STRING)</b>

Please note the above input params:

<b>DB_SRC</b> Named source database to grab tables from.

<b>SCHEMA_SRC</b> Named source Schema to use to grab tables from

<b>DB_DEST</b> Named destination database to land tables in

<b>SCHEMA_DEST</b>Named destination schema to land tables in

Please note that the s.proc will utilize <b>create SCHEMA if not exists</b> (for DB as well) as to avoid errors. Could have implications but most likely not.

<b>Please also note: This codebase is not supported/maintained in any way shape or form. You are to use this at your own risk.</b>
