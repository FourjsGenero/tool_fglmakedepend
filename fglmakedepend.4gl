OPTIONS SHORT CIRCUIT
IMPORT util
IMPORT os
&define MY_ASSERT_MSG(x,msg) IF NOT NVL(x,0) THEN \
     CALL myerr("ASSERTION failed:"||#x||","||msg) \
   END IF

MAIN
  DEFINE ok BOOLEAN
  DEFINE result,line,mod,arg,dname,name STRING
  DEFINE tok base.StringTokenizer
  DEFINE ch base.Channel
  DEFINE arr DYNAMIC ARRAY OF STRING
  IF num_args()<1 THEN
    DISPLAY sfmt("usage:%1 <program> <module>",arg_val(0))
    RETURN
  END IF
  LET arg=arg_val(1)
  CALL get_program_output(sfmt('fglrun --print-imports "%1"',arg)) RETURNING ok, result
  IF NOT ok THEN
    CALL myerr(result)
  END IF
  LET tok=base.StringTokenizer.create(result,"\n")
  WHILE tok.hasMoreTokens()
    LET line=tok.nextToken()
    --DISPLAY "line '",line,"' len:",line.getLength()
    MY_ASSERT_MSG(line.getLength()>0,"Line length must not be 0")
    CASE 
      WHEN line.getIndexOf("-- in",1)==1 
        IF dname IS NOT NULL THEN
          CALL writeDeps(dname,ch,arr)
          CALL ch.close()
          --DISPLAY "closed:",dname
          LET ch=NULL
          LET dname=NULL
        END IF
        MY_ASSERT_MSG((ch IS NULL) AND (dname IS NULL) ,"Channel must not be in use")
        LET dname=line.subString(7,line.getLength()-4),".d"
        LET ch=base.Channel.create()
        CALL ch.openFile(dname,"w")
        --DISPLAY "opened:",dname
      WHEN line.getIndexOf("IMPORT",1)==1
        MY_ASSERT_MSG((ch IS NOT NULL) AND (dname IS NOT NULL),"Channel must be initialized")
        LET name=line.subString(12,line.getLength())
        LET mod=name,".42m"
        IF NOT isInLibDir(mod) AND NOT mod.equals(arg) THEN
          LET arr[arr.getLength()+1]=name
          --IF os.Path.exists(mod) THEN
          --RUN sfmt("%1 %2",fgl_getenv("FGLMAKEDEPEND"),mod)
          --END IF
        ELSE
          --DISPLAY "ignore standard lib:",mod
        END IF
    END CASE
  END WHILE
  --check for last
  IF dname IS NOT NULL THEN
    CALL writeDeps(dname,ch,arr)
    CALL ch.close()
    --DISPLAY "closed:",dname
  END IF
END MAIN

PRIVATE FUNCTION writeDeps(dname STRING,ch base.Channel,arr DYNAMIC ARRAY OF STRING)
  DEFINE i,len INT
  DEFINE name,mod STRING
  LET mod=dname.subString(1,dname.getLength()-2),".42m"
  LET len=arr.getLength()
  FOR i=1 TO len
    LET name=arr[i],".4gl"
    IF i=1 THEN
      CALL ch.writeLine(sfmt("%1: %2%3",mod,name,IIF(len>1," \\","")))
    ELSE
      CALL ch.writeLine(sfmt("  %1%2",name,IIF(i<len," \\","")))
    END IF
  END FOR
  CALL arr.clear()
END FUNCTION

PRIVATE FUNCTION isInLibDir(mod STRING)
  DEFINE fgldir STRING
  DEFINE modinlibdir STRING
  LET fgldir=base.Application.getFglDir()
  LET modinlibdir=os.Path.join(os.Path.join(fgldir,"lib"),mod)
  RETURN os.Path.exists(modinlibdir)
END FUNCTION

PRIVATE FUNCTION myerr(errstr STRING)
  DEFINE ch base.Channel
  LET ch=base.Channel.create()
  CALL ch.openFile("<stderr>","w")
  CALL ch.writeLine(sfmt("ERROR:%1",errstr))
  CALL ch.close()
  EXIT PROGRAM 1
END FUNCTION

PRIVATE FUNCTION get_program_output(program STRING) RETURNS (BOOLEAN,STRING)
  DEFINE tmpName,errName STRING
  DEFINE code INTEGER
  DEFINE ok BOOLEAN
  DEFINE t TEXT
  DEFINE result STRING
  LET tmpName=os.Path.makeTempName()
  LET errName=os.Path.makeTempName()
  LET program=program,'> "',tmpName,'" 2>"',errName,'"'
  RUN program RETURNING code
  IF code THEN
    LOCATE t IN FILE errName
  ELSE
    LOCATE t IN FILE tmpName
    LET ok=TRUE
  END IF
  LET result=t
  CALL os.Path.delete(tmpName) RETURNING code
  CALL os.Path.delete(errName) RETURNING code
  RETURN ok,result
END FUNCTION
