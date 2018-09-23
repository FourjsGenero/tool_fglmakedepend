IMPORT FGL fglmakedepend
IMPORT FGL fgldialog
MAIN
  CALL fglmakedepend.main()
  CALL fgldialog.fgl_winMessage("a","b","c")
END MAIN
