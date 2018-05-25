
# Set Sequence

## Oracle PL/SQL solution to set sequence next value

(with appropriate granted privileges )
The **P_SET_SEQUENCE_TO_VALUE** procedure adjust a sequence next value to a certain number.
Definition:

    P_SET_SEQUENCE_TO_VALUE( I_SEQUENCE_NAME   in varchar2
                           , I_VALUE           in number default 0
                           ) 


The **P_SET_SEQUENCE_TO_TABLE** procedure adjust a sequence next value to a table max(id).
Definition:

    P_SET_SEQUENCE_TO_TABLE( I_TABLE_NAME       in varchar2
                           , I_COLUMN_NAME      in varchar2
                           , I_SEQUENCE_NAME    in varchar2 
                           )

