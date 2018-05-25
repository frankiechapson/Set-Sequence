
create or replace procedure P_SET_SEQUENCE_TO_VALUE( I_SEQUENCE_NAME   in varchar2
                                                   , I_VALUE           in number default 0
                                                   ) is

/* *********************************************************************************************************

    The P_SET_SEQUENCE_TO_VALUE procedure sets the next value of the I_SEQUENCE_NAME sequence to the I_VALUE.
    

    History of changes
    yyyy.mm.dd | Version | Author         | Changes
    -----------+---------+----------------+-------------------------
    2017.01.16 |  1.0    | Ferenc Toth    | Created 

************************************************************************************************************ */

    V_USER_SEQUENCE     user_sequences%rowtype;
    V_DIFFERENCE        number := 0;
    V_SQL               varchar2( 3000 );

begin
    -- save the current definition of the sequence
    select *
      into V_USER_SEQUENCE
      from user_sequences
     where sequence_name  = trim( upper( I_SEQUENCE_NAME ) );

    if nvl(I_VALUE,0) <= nvl( V_USER_SEQUENCE.min_value, 1 ) then

        execute immediate 'drop sequence '   || I_SEQUENCE_NAME ;   
        V_SQL := 'create sequence ' || I_SEQUENCE_NAME || ' increment by '||V_USER_SEQUENCE.increment_by;
        if V_USER_SEQUENCE.min_value is null then
            V_SQL := V_SQL || ' nominvalue ';
        else
            V_SQL := V_SQL || ' minvalue '||V_USER_SEQUENCE.min_value;
        end if;
        if V_USER_SEQUENCE.max_value is null then
            V_SQL := V_SQL || ' nomaxvalue ';
        else
            V_SQL := V_SQL || ' maxvalue '||V_USER_SEQUENCE.max_value;
        end if;
        V_SQL := V_SQL || ' start with '||V_USER_SEQUENCE.min_value;
        if V_USER_SEQUENCE.cycle_flag='N' then
            V_SQL := V_SQL || ' nocycle ';
        else
            V_SQL := V_SQL || ' cycle ';
        end if;
        if V_USER_SEQUENCE.order_flag='N' then
            V_SQL := V_SQL || ' noorder ';
        else
            V_SQL := V_SQL || ' order ';
        end if;
        if V_USER_SEQUENCE.cache_size=0 then
            V_SQL := V_SQL || ' nocache ';
        else
            V_SQL := V_SQL || ' cache '||V_USER_SEQUENCE.cache_size;
        end if;
        execute immediate V_SQL;

    else

        V_DIFFERENCE := nvl(I_VALUE,0) - V_USER_SEQUENCE.last_number;
        if V_DIFFERENCE > 0 then
            execute immediate 'alter sequence '  || I_SEQUENCE_NAME || ' increment by ' || V_DIFFERENCE ;
            execute immediate 'select '          || I_SEQUENCE_NAME || '.nextval from dual' into V_DIFFERENCE;
            execute immediate 'alter sequence '  || I_SEQUENCE_NAME || ' increment by 1';
        end if;

    end if;

end;
/



create or replace procedure P_SET_SEQUENCE_TO_TABLE( I_TABLE_NAME       in varchar2
                                                   , I_COLUMN_NAME      in varchar2
                                                   , I_SEQUENCE_NAME    in varchar2 
                                                   ) is 
/* **********************************************************************************************************

    The P_SET_SEQUENCE_TO_TABLE procedure sets the next value of the I_SEQUENCE_NAME sequence to the 
    max value + 1 of the I_COLUMN_NAME in the I_TABLE_NAME.
    

    History of changes
    yyyy.mm.dd | Version | Author         | Changes
    -----------+---------+----------------+-------------------------
    2017.01.16 |  1.0    | Ferenc Toth    | Created 

********************************************************************************************************** */

    V_MAXUSED         number; 

begin    
    execute immediate 'select coalesce(max(' || I_COLUMN_NAME || '),0) from '|| I_TABLE_NAME into V_MAXUSED; 
    V_MAXUSED := nvl( V_MAXUSED, 0 ) + 1;
    if V_MAXUSED > 1 then
        P_SET_SEQUENCE_TO_VALUE( I_SEQUENCE_NAME, V_MAXUSED ); 
    end if;
end;
/
