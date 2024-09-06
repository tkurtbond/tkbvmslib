$ !> DMS_SYMBOLS.COM -- Define poise dms symbols
$ add           :== $dms:add
$ asq 		:== $dms:asq
$ blank         :== $dms:blank
$ bog           :== $dms:bog
$ bwriter       :== @dms:batch
$ calcul*ate    :== $dms:calculate
$ card          :== $dms:card
$ commands      :== type sys$manager:commands.txt
$ compare       :== $dms:compare
$ correct       :== $ut:speller correct
$ desc*ribe     :== $dms:describe
$ dmenu         :== @dms:dmsmenu dms
$ dmsearch      :== $dms:search
$ dmsort        :== $dms:sort
$ editor        :== $dms:editor
$ execute       :== submit/notify/noprinter
$ expunge       :== $dms:expunge
$ extend        :== $dms:extend
$ form          :== $dms:form
$ header        :== $dms:header
$ key           :== $dms:purge
$ label         :== $dms:label
$ letter        :== $dms:letter
$ menu          :== @dms:dmsmenu
$ move          :== $dms:move
$ pointer       :== $dms:pointer
$ quebat*ch     :== $dms:quebatch
$ remove        :== $dms:delete
$ reorder       :== $dms:reorder
$ report        :== $dms:print
$ rotate        :== $dms:rotate
$ save          :== $dms:save
$ scope         :== $dms:scope
$ screen        :== $dms:screen
$! spell        :== $ut:speller spell
$ spool         :== print/notify
$ update        :== $dms:update
$ xtab          :== $dms:xtab
$!
$ vue		:== $ut:view
