;no space after MAIN
(defrule MAIN::ideal-duck-bachelor
	(bill big ?name)
	(feet wide ?name)
	=>
	(printout t "the ideal duck is" ?name crlf)
	(assert (move-to-front ?name)))
	
(defrule MAIN::move-to-front
	?move-to-front <- (move-to-front ?who)
	?old-list <- (list $?front ?who $?rear)
	=>
	(retract ?move-to-front ?old-list)
	(assert (list ?who ?front ?rear))
	(assert (change-list yes)))
	
(defrule MAIN::print-list
	?change-list <-(change-list yes)
	(list $?list)
	=>
	(retract ?change-list)
	(printout t "list is:" ?list crlf))
	