create or replace procedure SHARE_MV_CREATE(DB_SRC STRING, SCHEMA_SRC STRING, DB_DEST STRING, SCHEMA_DEST STRING)
    returns array
    language javascript
    strict
    execute as owner
    as
$$

var output = [];
var getTables = `SELECT TABLE_NAME FROM ${DB_SRC}.INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = '${SCHEMA_SRC}'`;
try {
  var tables = snowflake.execute({sqlText: getTables})
  while(tables.next()){
      var TABLE_NAME = tables.getColumnValue(1);

      //create DATABASE if not exists
      snowflake.execute ({sqlText: `create DATABASE if not exists ${DB_DEST}`});

      //create SCHEMA if not exists
      snowflake.execute ({sqlText: `create SCHEMA if not exists ${DB_DEST}.${SCHEMA_DEST}`});

      //Create MVs on all the tables above
      snowflake.execute ({sqlText: ` create or replace secure materialized view ${DB_DEST}.${SCHEMA_DEST}.${TABLE_NAME} as
                                     select * from ${DB_SRC}.${SCHEMA_SRC}.${TABLE_NAME} `});

      //log table create time for output
      output.push(`${DB_SRC}.${SCHEMA_SRC}.${TABLE_NAME} materialized : ${new Date()}`)
  }

}catch (err)  {
    return "Failed: " + err;   // Return a success/error indicator.
}

return output;

$$;

// CALL STORED PROC
call SHARE_MV_CREATE('MY_DB', 'MY_SCHEMA', 'DESTINATION_DB', 'DESINATION_SCHEMA');










