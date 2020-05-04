	
	mtype: states = {on, off};
	
	mtype:states hands = off;
	mtype:states dry = off;

	mtype:process = {upd, drr};
	
//    chan turn = [1] of {mtype:process} // holds
    chan turn = [0] of {mtype:process} // not holds, Spin inside atomic
    
	proctype Update()	{
	do
	:: { atomic {
			turn ? upd;	     
		    if
				:: hands = on
				:: hands = off
		    fi
		    turn ! drr
	      }
		}
	od
	}
	
	proctype Dryer() {
	do
	:: atomic{
		turn ? drr;
		if 
			:: (hands == on) -> dry = on; 
								turn ! upd;
			:: (hands == off) -> dry = off; 
								turn ! upd;
		fi
//		turn ! upd // 32, 34 delete; holds with 'turn = [1]', Spin dies with 'turn = [0]'.
		}
//		turn ! upd // 32, 34 delete; holds with 'turn = [1]', not holds with 'turn = [0]'
	od }

	init {
	  run Update();
	  run Dryer(); 
	  turn ! upd
	 }
	  	
     ltl p_ON {[]((hands == on) -> X(dry == on))} // yes

