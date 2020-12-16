create or replace procedure SHARE_MV_CREATE(DB_SRC STRING, SCHEMA_SRC STRING, DB_DEST STRING, SCHEMA_DEST STRING)
    returns array
    language javascript
    strict
    execute as owner
    as
$$

var output = [];
var getTables = `SELECT TABLE_NAME, TABLE_TYPE FROM ${DB_SRC}.INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = '${SCHEMA_SRC}'`;
try {
  var tables = snowflake.execute({sqlText: getTables})
  while(tables.next()){
      var TABLE_NAME = tables.getColumnValue(1);
      var TABLE_TYPE = tables.getColumnValue(2);
      var log = {};
      //create DATABASE if not exists
      snowflake.execute ({sqlText: `create DATABASE if not exists ${DB_DEST}`});
      log.table = TABLE_NAME;
      log.type =  TABLE_TYPE;
      //create SCHEMA if not exists
      snowflake.execute ({sqlText: `create SCHEMA if not exists ${DB_DEST}.${SCHEMA_DEST}`});

      if(TABLE_TYPE == 'BASE TABLE'){
          var sql = ` create or replace table ${DB_DEST}.${SCHEMA_DEST}.${TABLE_NAME} as select * from ${DB_SRC}.${SCHEMA_SRC}.${TABLE_NAME} `;
          log.sql = sql;
          log.start = new Date();
          snowflake.execute ({sqlText: sql});      
          log.end = new Date();

      }else if(TABLE_TYPE == 'MATERIALIZED VIEW'){ //CANNOT CREATE MV FROM EXISTIN MV --> WILL NEED TO CREATE A TABLE (CTAS)
          var sql = ` create or replace table ${DB_DEST}.${SCHEMA_DEST}.${TABLE_NAME} as select * from ${DB_SRC}.${SCHEMA_SRC}.${TABLE_NAME} `
          log.sql = sql;
          log.start = new Date();
          snowflake.execute ({sqlText: sql });
          log.end = new Date();
          
      }else if(TABLE_TYPE == 'VIEW'){
          var sql = ` create or replace secure view ${DB_DEST}.${SCHEMA_DEST}.${TABLE_NAME} as select * from ${DB_SRC}.${SCHEMA_SRC}.${TABLE_NAME} `;
          log.sql = sql;
          log.start = new Date();
          snowflake.execute ({sqlText: sql});     
          log.end = new Date();
      }
      
      output.push(log)
  }

}catch (err)  {
    return ["Failed: " + err];   // Return a success/error indicator.
}

return output;

$$;


call SHARE_MV_CREATE('SRC_DB', 'SRC_SCHEMA', 'DEST_DB', 'DEST_SCHEMA');











